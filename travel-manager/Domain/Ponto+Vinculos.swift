//
//  Ponto+Vinculos.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import Foundation

extension Ponto {
    var listaParadas: [Parada] { paradas ?? [] }
    var listaDespesas: [Despesa] { despesas ?? [] }
    
    var paradasOrdenadas: [Parada] {
        listaParadas.sorted {
            $0.inicio > $1.inicio
        }
    }
    
    var despesasOrdenadas: [Despesa] {
        listaDespesas.sorted {
            $0.data > $1.data
        }
    }
    
    var tempoParada: TimeInterval {
        var total: TimeInterval = 0
        
        for p in listaParadas {
            total += p.duracao
        }
        
        return total
    }
    
    var totalGasto: Decimal {
        var soma: Decimal = 0
        
        for d in listaDespesas {
            soma += d.valor
        }
        
        return soma
    }
}
