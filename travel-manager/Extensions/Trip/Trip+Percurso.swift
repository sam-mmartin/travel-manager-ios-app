//
//  Trip+Percurso.swift
//  travel-manager
//
//  Created by Samuel on 23/10/26.
//
import Foundation

extension Trip {
    var pontosOrdenados: [Ponto] {
        (pontos ?? []).sorted {
            if $0.horario != $1.horario {
                return $0.horario < $1.horario
            }
            
            return $0.odometro < $1.odometro
        }
    }
    
    var chegou: Bool { fim != nil && odometroFinal != nil }
    var origemNome: String { origem.isEmpty ? "Origem" : origem }
    var destinoNome: String { destino.isEmpty ? "Destino" : destino }
    var rotaTexto: String { origemNome + " -> " + destinoNome }
    
    var percurso: [PontoPercurso] {
        var lista: [PontoPercurso] = []
        lista.append(PontoPercurso(nome: origemNome,
                                   horario: inicio,
                                   odometro: odometroInicial))
        
        for p in pontosOrdenados {
            lista.append(PontoPercurso(nome: p.nome,
                                       horario: p.horario,
                                       odometro: p.odometro))
        }
        
        if chegou, let fim, let odometroFinal {
            lista.append(PontoPercurso(nome: destinoNome,
                                       horario: fim,
                                       odometro: odometroFinal))
        }
        
        return lista
    }
    
    var trechos: [Trecho] {
        let lista = percurso
        var resultado: [Trecho] = []
        
        if lista.count < 2 { return resultado }
        
        for i in 1..<lista.count {
            resultado.append(Trecho(
                id: i,
                origem: lista[i - 1],
                destino: lista[i]
            ))
        }
        
        return resultado
    }
    
    var percursoKm: Double {
        let lista = percurso
        guard let a = lista.first, let b = lista.last else { return 0 }
        
        return max(0, b.odometro - a.odometro)
    }
    
    var percursoDuracao: TimeInterval {
        let lista = percurso
        guard let a = lista.first, let b = lista.last else { return 0 }
        
        return max(0, b.horario.timeIntervalSince(a.horario))
    }
    
    func erroDePonto(horario: Date, odometro: Double?) -> String? {
        if horario < inicio {
            return "O horário é anterior à partida da viagem."
        }
        
        guard let odo = odometro else { return nil }
        
        var anterior: PontoPercurso?
        var proximo: PontoPercurso?
        
        for p in percurso {
            if p.horario <= horario {
                anterior = p
            } else if proximo == nil {
                proximo = p
            }
        }
        
        if let a = anterior, odo < a.odometro {
            return "O odômetro é menor que o de " + a.nome + "."
        }
        
        if let p = proximo, odo > p.odometro {
            return "O odômetro é maior que o de " + p.nome + ", que vem depois."
        }
        
        return nil
    }
}
