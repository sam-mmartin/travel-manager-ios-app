//
//  Viagem+Paradas.swift
//  travel-manager
//
//  Created by Samuel on 23/10/26.
//
import Foundation
import SwiftData

extension Viagem {
    var listaParadas: [Parada] { paradas ?? [] }
    
    var paradasOrdenadas: [Parada] {
        listaParadas.sorted {
            $0.inicio > $1.inicio
        }
    }
    
    var ultimaParada: Parada? { paradasOrdenadas.first }
    
    var paradaAberta: Parada? {
        listaParadas.first { $0.fim == nil }
    }
    
    var tempoParado: TimeInterval {
        var total: TimeInterval = 0
        
        for p in listaParadas {
            total += p.duracao
        }
        
        return total
    }
    
    @discardableResult
    func iniciarParada(em context: ModelContext) -> Parada? {
        guard paradaAberta == nil else {
            return nil
        }
        
        let parada = Parada()
        context.insert(parada)
        parada.viagem = self
        
        return parada
    }
    
    func encerrarParadaAberta(horario: Date = .now) {
        paradaAberta?.fim = horario
    }
}
