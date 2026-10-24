//
//  NomeDoLocal.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import Foundation
import CoreLocation
import MapKit

enum NomeDoLocal {
    static func buscar(para coordenada: Coordenada) async -> String? {
        let local = CLLocation(latitude: coordenada.latitude,
                               longitude: coordenada.longitude)
        
        guard let pedido = MKReverseGeocodingRequest(location: local),
              let itens = try? await pedido.mapItems,
              let item = itens.first else {
            return nil
        }
        
        if item.pointOfInterestCategory != nil,
           let nome = item.name?.limpo, !nome.isEmpty {
            return nome
        }
        
        
        if let curto = item.address?.shortAddress?.limpo, !curto.isEmpty {
            return curto
        }
        
        if let nome = item.name?.limpo, !nome.isEmpty {
            return nome
        }
        
        return item.address?.fullAddress.limpo
    }
}
