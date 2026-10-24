//
//  Trecho.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import Foundation
import SwiftData

struct Trecho: Identifiable {
    let origem: Ponto
    let destino: Ponto
    
    var id: PersistentIdentifier {
        destino.persistentModelID
    }
    
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
