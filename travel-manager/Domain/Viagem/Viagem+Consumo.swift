//
//  Viagem+Consumo.swift
//  travel-manager
//
//  Created by Samuel on 23/10/26.
//
import Foundation
import SwiftData

extension Viagem {
    /// Consumo medido entre um abastecimento e o anterior
    struct TrechoConsumo {
        let id: PersistentIdentifier
        let km: Double
        let litros: Double
        var consumo: Double { km / litros }
    }
    
    private var abastecimentosValidos: [Despesa] {
        var lista: [Despesa] = []
        
        for d in listaDespesas {
            if d.categoria == .combustivel, d.odometro != nil, d.litrosEfetivos != nil {
                lista.append(d)
            }
        }
        
        lista.sort { ($0.odometro ?? 0) < ($1.odometro ?? 0) }
        
        return lista
    }
    
    var trechoConsumo: [TrechoConsumo] {
        let lista = abastecimentosValidos
        var trechos: [TrechoConsumo] = []
        if lista.count < 2 { return trechos }
        
        for i in 1..<lista.count {
            let anterior = lista[i - 1]
            let atual = lista[i]
            let litros = atual.litrosEfetivos ?? 0
            let km = (atual.odometro ?? 0) - (anterior.odometro ?? 0)
            
            if km > 0 && litros > 0 {
                trechos.append(
                    TrechoConsumo(id: atual.persistentModelID,
                                  km: km,
                                  litros: litros))
            }
        }
        
        return trechos
    }
    
    func consumo(de despesa: Despesa) -> Double? {
        trechoConsumo.first {
            $0.id == despesa.persistentModelID
        }?.consumo
    }
    
    var consumoMedio: Double? {
        let trechos = trechoConsumo
        var km: Double = 0
        var litros: Double = 0
        
        for t in trechos {
            km += t.km
            litros += t.litros
        }
        
        guard litros > 0 else { return nil }
        
        return km / litros
    }
}
