//
//  Ponto.swift
//  travel-manager
//
//  Created by Samuel on 22/10/26.
//
import Foundation
import SwiftData

@Model
final class Ponto {
    var nome: String = ""
    var horario: Date = Date()
    var odometro: Double = 0
    var latitude: Double?
    var longitude: Double?
    var tipo: TipoPonto = TipoPonto.intermediario
    var trip: Trip?
    
    @Relationship(deleteRule: .nullify, inverse: \Expense.ponto)
    var despesas: [Expense]? = []
    
    init(nome: String, horario: Date = .now, odometro: Double,
         coordenada: Coordenada? = nil,
         tipo: TipoPonto = .intermediario) {
        self.nome = nome
        self.horario = horario
        self.odometro = odometro
        self.latitude = coordenada?.latitude
        self.longitude = coordenada?.longitude
        self.tipo = tipo
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

