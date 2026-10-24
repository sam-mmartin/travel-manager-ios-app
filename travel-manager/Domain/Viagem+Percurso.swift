//
//  Viagem+Percurso.swift
//  travel-manager
//
//  Created by Samuel on 23/10/26.
//
import Foundation

extension Viagem {
    // MARK: Pontos fixos
    
    var pontoPartida: Ponto? {
        (pontos ?? []).first {
            $0.tipo == .partida
        }
    }
    
    var pontoChegada: Ponto? {
        (pontos ?? []).first {
            $0.tipo == .chegada
        }
    }
    
    var chegou: Bool { pontoChegada != nil }
    
    // MARK: Dados derivados dos pontos
    
    var inicio: Date { pontoPartida?.horario ?? criadaEm }
    var fim: Date? { pontoChegada?.horario }
    var odometroInicial: Double { pontoPartida?.odometro ?? 0 }
    var odometroFinal: Double? { pontoChegada?.odometro }
    
    var origemNome: String { pontoPartida?.nome ?? "Origem" }
    var destinoNome: String { destino.isEmpty ? "Destino" : destino }
    var rotaTexto: String { origemNome + " -> " + destinoNome }
    
    // MARK: Ordem do percurso
    
    /// So os pontos intermediarios, por horario (o odometro desempata)
    var pontosOrdenados: [Ponto] {
        var lista: [Ponto] = []
        
        for p in pontos ?? [] {
            if p.tipo == .intermediario {
                lista.append(p)
            }
        }
        
        lista.sort {
            if $0.horario != $1.horario {
                return $0.horario < $1.horario
            }
            
            return $0.odometro < $1.odometro
        }
        
        return lista
    }
    
    
    var pontosDoPercurso: [Ponto] {
        var lista: [Ponto] = []
        if let partida = pontoPartida { lista.append(partida) }
        
        lista.append(contentsOf: pontosOrdenados)
        
        if let chegada = pontoChegada { lista.append(chegada) }
        
        return lista
    }
    
    var trechos: [Trecho] {
        let lista = pontosDoPercurso
        var resultado: [Trecho] = []
        
        if lista.count < 2 { return resultado }
        
        for i in 1..<lista.count {
            resultado.append(Trecho(
                origem: lista[i - 1],
                destino: lista[i]
            ))
        }
        
        return resultado
    }
    
    var percursoKm: Double {
        let lista = pontosDoPercurso
        guard let a = lista.first, let b = lista.last else { return 0 }
        
        return max(0, b.odometro - a.odometro)
    }
    
    var percursoDuracao: TimeInterval {
        let lista = pontosDoPercurso
        guard let a = lista.first, let b = lista.last else { return 0 }
        
        return max(0, b.horario.timeIntervalSince(a.horario))
    }
    
    // MARK: Validacoes
    
    func erroDePonto(horario: Date, odometro: Double?) -> String? {
        if horario < inicio {
            return "O horário é anterior à partida da viagem."
        }
        
        if let fim, horario >= fim {
            return "O horário deve ser anterior à chegada da viagem."
        }
        
        guard let odo = odometro else { return nil }
        
        var anterior: Ponto?
        var proximo: Ponto?
        
        for p in pontosDoPercurso {
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
    
    func erroDeChegada(horario: Date, odometro: Double?) -> String? {
        guard let ultimo = pontosDoPercurso.last else {
            return nil
        }
        
        if horario < ultimo.horario {
            return "O horário é anterior ao último ponto registrado."
        }
        
        guard let odo = odometro else {
            return nil
        }
        
        if odo < ultimo.odometro {
            return "O odômetro é menor que o do último ponto."
        }
        
        return nil
    }
}
