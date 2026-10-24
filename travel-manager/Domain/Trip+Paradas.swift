//
//  Trip+Paradas.swift
//  travel-manager
//
//  Created by Samuel on 23/10/26.
//
import Foundation

extension Trip {
    var listaParadas: [Parada] { paradas ?? [] }
    
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
    
}
