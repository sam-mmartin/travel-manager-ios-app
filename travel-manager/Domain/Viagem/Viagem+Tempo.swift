//
//  Viagem+Tempo.swift
//  travel-manager
//
//  Created by Samuel on 25/10/26.
//
import Foundation

extension Parada {
    /// Quanto desta parada cai dentro do intervalo. Parada aberta conta até agora.
    func sobreposicao(com intervalo: ClosedRange<Date>) -> TimeInterval {
        let ini = max(inicio, intervalo.lowerBound)
        let fimEfetivo = min(fim ?? Date.now, intervalo.upperBound)
        
        return max(0, fimEfetivo.timeIntervalSince(ini))
    }
    
    /// A parada cobre o horário do ponto: começou antes (ou junto) e terminou depois.
    func cobreHorarioDe(_ ponto: Ponto) -> Bool {
        inicio <= ponto.horario && (fim ?? Date.now) >= ponto.horario
    }
}

extension Viagem {
    var intervaloDoPercurso: ClosedRange<Date>? {
        guard let a = pontosDoPercurso.first,
              let fim = fimDoPercurso,
              fim >= a.horario else {
            return nil
        }
        
        return a.horario...fim
    }
    
    var tempoParadoNoPercurso: TimeInterval {
        guard let intervalo = intervaloDoPercurso else {
            return 0
        }
        
        var total: TimeInterval = 0
        
        for p in listaParadas {
            total += p.sobreposicao(com: intervalo)
        }
        
        return min(total, percursoDuracao)
    }
    
    var tempoEmMovimento: TimeInterval {
        max(0, percursoDuracao - tempoParadoNoPercurso)
    }
}
