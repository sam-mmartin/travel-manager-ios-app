//
//  ExpenseFormState.swift
//  travel-manager
//
//  Created by Samuel on 23/10/26.
//
import Foundation
import SwiftData
import Observation

enum ModoPonto: String, CaseIterable, Identifiable {
    case existente = "Existente"
    case novo = "Novo"
    case nenhum = "Nenhum"
    
    var id: String { rawValue }
}

@Observable
final class ExpenseFormState {
    let trip: Trip
    
    var categoria: Categoria
    var valor: Decimal?
    var descricao = ""
    var data = Date()
    var litros: Double?
    var precoLitro: Decimal?
    
    var modo: ModoPonto
    var pontoID: PersistentIdentifier?
    var novoNome = ""
    var novoOdometro: Double?
    var novaCoordenada: Coordenada?
    
    
    init(trip: Trip, categoriaInicial: Categoria = .combustivel) {
        self.trip = trip
        self.categoria = categoriaInicial
        
        let ultimo = trip.pontosDoPercurso.last
        self.modo = .novo
        self.pontoID = ultimo?.persistentModelID
        self.novoOdometro = trip.odometroAtual
    }
    
    // MARK: Combustivel
    
    var litrosCalculados: Double? {
        guard litros == nil,
              let valor = valor,
              let preco = precoLitro,
              preco > 0 else {
            return nil
        }
        
        return NSDecimalNumber(decimal: valor / preco).doubleValue
    }
    
    var precoCalculado: Decimal? {
        guard precoLitro == nil,
              let valor = valor, valor > 0,
              let litros = litros, litros > 0 else {
            return nil
        }
        
        return valor / Decimal(litros)
    }
    
    var textoLitrosEstimados: String? {
        guard let l = litrosCalculados else {
            return nil
        }
        
        let n = l.formatted(.number.precision(
            .fractionLength(2)
        ))
        
        return "Litros estimados: " + n + " L"
    }
    
    var textoPrecoEstimado: String? {
        guard let p = precoCalculado else {
            return nil
        }
        
        return "Preço do litro estimado: " + p.moedaCasas(2)
    }
    
    // MARK: Ponto
    
    var pontoSelecionado: Ponto? {
        guard let pontoID else {
            return nil
        }
        
        return trip.pontosDoPercurso.first {
            $0.persistentModelID == pontoID
        }
    }
    
    var erroNovoPonto: String? {
        guard modo == .novo else {
            return nil
        }
        
        return trip.erroDePonto(horario: data,
                                odometro: novoOdometro)
    }
    
    var novoPontoCompleto: Bool {
        let nomeOk = !novoNome.trimmingCharacters(in: .whitespaces).isEmpty
        
        return nomeOk && novoOdometro != nil
    }
    
    func rotulo(_ p: Ponto) -> String {
        var texto = p.nome
        
        if let tipo = p.tipo.rotulo {
            texto += " (" + tipo + ")"
        }
        
        return texto + " • " + p.odometro.kmTexto
    }
    
    // MARK: Validacao e Gravacao
    
    var podeSalvar: Bool {
        guard (valor ?? 0) > 0 else {
            return false
        }
        
        switch modo {
        case .nenhum:
            return true
        case .existente:
            return pontoSelecionado != nil
        case .novo:
            return novoPontoCompleto && erroNovoPonto == nil
        }
    }
    
    func salvar(em context: ModelContext) {
        let despesa = Expense(categoria: categoria,
                              valor: valor ?? 0,
                              descricao: descricao,
                              data: data,
                              litros: categoria == .combustivel ? litros : nil,
                              precoLitro: categoria == .combustivel ? precoLitro : nil)
        
        context.insert(despesa)
        despesa.trip = trip
        
        switch modo {
        case .existente:
            despesa.ponto = pontoSelecionado
        case .novo:
            let nome = novoNome.trimmingCharacters(in: .whitespaces)
            let ponto = Ponto(nome: nome,
                              horario: data,
                              odometro: novoOdometro ?? 0,
                              coordenada: novaCoordenada)
            context.insert(ponto)
            ponto.trip = trip
            despesa.ponto = ponto
        case .nenhum:
            break
        }
    }
}
