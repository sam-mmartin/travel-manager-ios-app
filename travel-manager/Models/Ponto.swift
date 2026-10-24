//
//  Ponto.swift
//  travel-manager
//
//  Created by Samuel on 22/10/26.
//
import Foundation
import SwiftData

struct Coordenada: Equatable, Sendable {
    var latitude: Double
    var longitude: Double
}

@Model
final class Ponto {
    var nome: String = ""
    var horario: Date = Date()
    var odometro: Double = 0
    var latitude: Double?
    var longitude: Double?
    var trip: Trip?
    
    @Relationship(deleteRule: .nullify, inverse: \Expense.ponto)
    var despesas: [Expense]? = []
    
    init(nome: String, horario: Date = .now, odometro: Double,
         coordenada: Coordenada? = nil) {
        self.nome = nome
        self.horario = horario
        self.odometro = odometro
        self.latitude = coordenada?.latitude
        self.longitude = coordenada?.longitude
    }
    
    var coordenada: Coordenada? {
        get {
            guard let latitude,
                  let longitude else {
                return nil
            }
            
            return Coordenada(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = newValue?.latitude
            longitude = newValue?.longitude
        }
    }
    
    var temLocalizacao: Bool {
        coordenada != nil
    }
}

struct PontoPercurso {
    let nome: String
    let horario: Date
    let odometro: Double
}

struct Trecho: Identifiable {
    let id: Int
    let origem: PontoPercurso
    let destino: PontoPercurso
    
    var km: Double {
        max(0, destino.odometro - origem.odometro)
    }
    
    var duracao: TimeInterval {
        max(0, destino.horario.timeIntervalSince(origem.horario))
    }
    
    var velocidadeMedia: Double? {
        guard km > 0, duracao > 0 else { return nil }
        
        return km / (duracao / 3600)
    }
}
