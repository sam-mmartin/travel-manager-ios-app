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
    
    var temVinculos: Bool {
        !listaParadas.isEmpty || !listaDespesas.isEmpty
    }
    
    var resumoVinculos: String {
        var partes: [String] = []
        
        let d = listaDespesas.count
        let p = listaParadas.count
        
        if d > 0 { partes.append(d == 1 ? "1 despesa" : "\(d) despesas")}
        if p > 0 { partes.append(p == 1 ? "1 parada" : "\(p) paradas")}
        
        return partes.joined(separator: " e ")
    }
    
    var paradasOrdenadas: [Parada] {
        listaParadas.sorted {
            $0.inicio > $1.inicio
        }
    }
    
    var tempoParada: TimeInterval {
        var total: TimeInterval = 0
        
        for p in listaParadas {
            total += p.duracao
        }
        
        return total
    }
    
    var despesasOrdenadas: [Despesa] {
        listaDespesas.sorted {
            $0.data > $1.data
        }
    }
    
    var totalGasto: Decimal {
        var soma: Decimal = 0
        
        for d in listaDespesas {
            soma += d.valor
        }
        
        return soma
    }
}
