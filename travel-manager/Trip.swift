//
//  Trip.swift
//  travel-manager
//
//  Created by Samuel on 18/10/26.
//
import Foundation
import SwiftData

@Model
final class Trip {
    var nome: String = ""
    var inicio: Date = Date()
    var fim: Date?
    var odometroInicial: Double = 0
    var odometroFinal: Double?
    var origem: String = ""
    var destino: String = ""
    
    @Relationship(deleteRule: .cascade, inverse: \Expense.trip)
    var despesas: [Expense]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Parada.trip)
    var paradas: [Parada]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Ponto.trip)
    var pontos: [Ponto]? = []
    
    var listaDespesas: [Expense] { despesas ?? [] }
    var listaParadas: [Parada] { paradas ?? [] }
    
    var paradaAberta: Parada? {
        listaParadas.first { $0.fim == nil }
    }
    
    var pontosOrdenados: [Ponto] {
        (pontos ?? []).sorted {
            if $0.horario != $1.horario { return $0.horario < $1.horario }
            
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
    
    var tempoParado: TimeInterval {
        var total: TimeInterval = 0
        
        for p in listaParadas {
            total += p.duracao
        }
        
        return total
    }
    
    var totalGasto: Decimal {
        listaDespesas.reduce(0) { $0 + $1.valor }
    }
    
    func total(de categoria: Categoria) -> Decimal {
        var soma: Decimal = 0
        
        for d in listaDespesas {
            if d.categoria == categoria {
                soma += d.valor
            }
        }
        
        return soma
    }
    
    var odometroAtual: Double {
        if chegou, let odometroFinal { return odometroFinal }
        var maior = odometroInicial
        
        for p in pontosOrdenados {
            maior = max(maior, p.odometro)
        }
        
        for d in listaDespesas {
            if let o = d.odometro { maior = max(maior, o) }
        }
        
        return maior
    }
    
    var kmPercorrido: Double {
        max(0, odometroAtual - odometroInicial)
    }
    
    var litrosAbastecidos: Double {
        listaDespesas.filter { $0.categoria == .combustivel }
            .compactMap(\.litrosEfetivos)
            .reduce(0, +)
    }
    
    struct TrechoConsumo {
        let id: PersistentIdentifier
        let km: Double
        let litros: Double
        var consumo: Double { km / litros }
    }
    
    private var abastecimentosValidos: [Expense] {
        var lista: [Expense] = []
        
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
            let odometroAnt = anterior.odometro ?? 0
            let odometroAtu = atual.odometro ?? 0
            let litros = atual.litrosEfetivos ?? 0
            let km = odometroAtu - odometroAnt
            
            if km > 0 && litros > 0 {
                trechos.append(TrechoConsumo(id: atual.persistentModelID,
                                             km: km,
                                             litros: litros))
            }
        }
        
        return trechos
    }
    
    func consumo(de despesa: Expense) -> Double? {
        trechoConsumo.first { $0.id == despesa.persistentModelID }?.consumo
    }
    
    var consumoMedio: Double? {
        let trechos = trechoConsumo
        let km = trechos.reduce(0) { $0 + $1.km }
        let litros = trechos.reduce(0) { $0 + $1.litros }
        guard litros > 0 else { return nil }
        
        return km / litros
    }
    
    var custoPorKm: Decimal? {
        guard kmPercorrido > 0 else { return nil}
        
        return totalGasto / Decimal(kmPercorrido)
    }
    
    init(nome: String, origem: String = "", destino: String = "",
         inicio: Date = .now, odometroInicial: Double = 0) {
        self.nome = nome
        self.origem = origem
        self.destino = destino
        self.inicio = inicio
        self.odometroInicial = odometroInicial
    }
}
