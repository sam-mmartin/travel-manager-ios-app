//
//  Trip+Ciclo.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import Foundation
import SwiftData

extension Trip {
    /// Cria a viagem ja com o ponto de partida
    @discardableResult
    static func criar(nome: String, origem: String, destino: String,
                      horario: Date, odometro: Double,
                      coordenada: Coordenada? = nil,
                      em context: ModelContext) -> Trip {
        let trip = Trip(nome: nome, destino: destino)
        
        let partida = Ponto(nome: origem,
                            horario: horario,
                            odometro: odometro,
                            coordenada: coordenada,
                            tipo: .partida)
        
        context.insert(trip)
        context.insert(partida)
        partida.trip = trip
        
        return trip
    }
    
    /// Cria o ponto de chegada. Nao faz nada se a viagem ja terminou
    func registrarChegada(nome: String, horario: Date, odometro: Double,
                          coordenada: Coordenada? = nil,
                          em context: ModelContext) {
        guard pontoChegada == nil else {
            return
        }
        
        let chegada = Ponto(nome: nome,
                            horario: horario,
                            odometro: odometro,
                            coordenada: coordenada,
                            tipo: .chegada)
        
        context.insert(chegada)
        chegada.trip = self
    }
    
    /// Remove o ponto de chegada. As despesas ligadas a ele ficam sem local.
    func reabrir(em context: ModelContext) {
        if let chegada = pontoChegada {
            context.delete(chegada)
        }
    }
}
