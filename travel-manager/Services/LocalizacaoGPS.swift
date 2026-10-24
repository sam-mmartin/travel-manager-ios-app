//
//  LocalizacaoGPS.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import Foundation
import CoreLocation
import Observation

@MainActor
@Observable
final class LocalizacaoGPS: NSObject, CLLocationManagerDelegate {
    enum Estado: Equatable {
        case parado
        case buscando
        case obtido(Coordenada)
        case negado
        case erro(String)
    }
    
    var estado: Estado = .parado
    
    @ObservationIgnored private let manager = CLLocationManager()
    @ObservationIgnored private var tempoLimite: Task<Void, Never>?
    
    /// Segundos de espera antes de desistir
    private let segundosLimite = 20
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func capturar() {
        estado = .buscando
        
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            estado = .negado
        default:
            iniciarLeitura()
        }
    }
    
    private func iniciarLeitura() {
        manager.startUpdatingLocation()
        
        tempoLimite?.cancel()
        let segundos = segundosLimite
        tempoLimite = Task { [weak self] in
            try? await Task.sleep(for: .seconds(segundos))
            
            guard !Task.isCancelled else {
                return
            }
            
            self?.expirou()
        }
    }
    
    private func finalizar(com novoEstado: Estado) {
        tempoLimite?.cancel()
        manager.stopUpdatingLocation()
        estado = novoEstado
    }
    
    private func expirou() {
        guard estado == .buscando else {
            return
        }
        
        finalizar(com: .erro(
            "Não foi possível determinar a posição. No simulador, defina uma localização em Features > Location."
        ))
    }
    
    private func autorizacaoMudou(_ status: CLAuthorizationStatus) {
        guard estado == .buscando else { return }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            iniciarLeitura()
        case .restricted, .denied:
            finalizar(com: .negado)
        default:
            break
        }
    }
    
    private func receber(_ coordenada: Coordenada) {
        guard estado == .buscando else {
            return
        }
        
        finalizar(com: .obtido(coordenada))
    }
    
    private func tratarErro(codigo: CLError.Code?, mensagem: String) {
        guard estado == .buscando else {
            return
        }
        
        switch codigo {
        case .locationUnknown:
            break
        case .denied:
            finalizar(com: .negado)
        default:
            finalizar(com: .erro(mensagem))
        }
    }
    
    // MARK: CLLocationManagerDelegate
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        Task { @MainActor in
            self.autorizacaoMudou(status)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didUpdateLocations locations: [CLLocation]) {
        guard let local = locations.last(where: {
            $0.horizontalAccuracy >= 0
        }) else {
            return
        }
        
        let coordenada = Coordenada(latitude: local.coordinate.latitude,
                                    longitude: local.coordinate.longitude)
        
        Task { @MainActor in
            self.receber(coordenada)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didFailWithError error: Error) {
        let codigo = (error as? CLError)?.code
        let mensagem = error.localizedDescription
        
        Task { @MainActor in
            self.tratarErro(codigo: codigo, mensagem: mensagem)
        }
    }
}
