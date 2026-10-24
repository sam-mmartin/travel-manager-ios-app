//
//  Trip+Quilometragem.swift
//  travel-manager
//
//  Created by Samuel on 23/10/26.
//
import Foundation

extension Trip {
    /// Odômetro final, se a viagem terminou; senão, o maior odômetro entre os pontos.
    var odometroAtual: Double {
        var maior = odometroInicial
        
        for p in pontosDoPercurso {
            maior = max(maior, p.odometro)
        }
    
        return maior
    }
    
    var kmPercorrido: Double { percursoKm }
    
    var custoPorKm: Decimal? {
        guard kmPercorrido > 0 else { return nil}
        
        return totalGasto / Decimal(kmPercorrido)
    }
}
