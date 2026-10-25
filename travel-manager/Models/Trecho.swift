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
    let paradas: [Parada]
    
    var id: PersistentIdentifier {
        destino.persistentModelID
    }
    
    var km: Double {
        max(0, destino.odometro - origem.odometro)
    }
    
    var duracaoTotal: TimeInterval {
        max(0, destino.horario.timeIntervalSince(origem.horario))
    }
    
    var inicioEmMovimento: Date {
        var inicio = origem.horario
        
        for p in paradas {
            if p.cobreHorarioDe(origem) {
                inicio = max(inicio, p.fim ?? Date.now)
            }
        }
        
        return min(inicio, destino.horario)
    }
    
    var duracao: TimeInterval {
        let inicio = inicioEmMovimento
        let fim = destino.horario
        
        guard fim > inicio else {
            return 0
        }
        
        let intervalo = inicio...fim
        var parado: TimeInterval = 0
        
        for p in paradas {
            if !p.cobreHorarioDe(origem) {
                parado += p.sobreposicao(com: intervalo)
            }
        }
        
        return max(0, fim.timeIntervalSince(inicio) - parado)
    }
    
    var tempoParado: TimeInterval {
        max(0, duracaoTotal - duracao)
    }
    
    var velocidadeMedia: Double? {
        guard km > 0, duracao > 0 else { return nil }
        
        return km / (duracao / 3600)
    }
}
