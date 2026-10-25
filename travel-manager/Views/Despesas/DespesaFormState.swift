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
final class DespesaFormState {
    let viagem: Viagem
    let editando: Despesa?
    
    var categoria: Categoria
    var valor: Decimal?
    var descricao = ""
    var data = Date()
    var litros: Double?
    var precoLitro: Decimal?
    
    var modo: ModoPonto
    var pontoID: PersistentIdentifier?
    var paradaID: PersistentIdentifier?
    var novoNome = ""
    var novoOdometro: Double?
    var novaCoordenada: Coordenada?
    
    
    init(viagem: Viagem, categoriaInicial: Categoria = .combustivel) {
        self.viagem = viagem
        self.editando = nil
        self.categoria = categoriaInicial
        
        let ultimo = viagem.pontosDoPercurso.last
        self.modo = .novo
        self.pontoID = ultimo?.persistentModelID
        self.novoOdometro = viagem.odometroAtual
        self.paradaID = viagem.paradaAberta?.persistentModelID
    }
    
    init(viagem: Viagem, editando despesa: Despesa) {
        self.viagem = viagem
        self.editando = despesa
        self.categoria = despesa.categoria
        self.valor = despesa.valor
        self.descricao = despesa.descricao
        self.data = despesa.data
        self.litros = despesa.litros
        self.precoLitro = despesa.precoLitro
        self.paradaID = despesa.parada?.persistentModelID
        self.novoOdometro = viagem.odometroAtual
        
        if let ponto = despesa.ponto {
            self.modo = .existente
            self.pontoID = ponto.persistentModelID
        } else {
            self.modo = .nenhum
            self.pontoID = nil
        }
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
        
        return viagem.pontosDoPercurso.first {
            $0.persistentModelID == pontoID
        }
    }
    
    var erroNovoPonto: String? {
        guard pontoDeParada == nil, modo == .novo else {
            return nil
        }
        
        return viagem.erroDePonto(horario: data,
                                  odometro: novoOdometro)
    }
    
    var novoPontoCompleto: Bool {
        let nomeOk = !novoNome.trimmingCharacters(in: .whitespaces).isEmpty
        
        return nomeOk && novoOdometro != nil
    }
    
    var paradaSelecionada: Parada? {
        guard let paradaID else {
            return nil
        }
        
        return viagem.listaParadas.first {
            $0.persistentModelID == paradaID
        }
    }
    
    var pontoDeParada: Ponto? {
        paradaSelecionada?.ponto
    }
    
    func rotulo(_ p: Ponto) -> String {
        var texto = p.nome
        
        if let tipo = p.tipo.rotulo {
            texto += " (" + tipo + ")"
        }
        
        return texto + " • " + p.odometro.kmTexto
    }
    
    func rotulo(_ p: Parada) -> String {
        var texto = p.titulo
        texto += " • " + p.inicio.formatted(date: .abbreviated,
                                            time: .shortened)
        
        if p.emAndamento {
            texto += " (em andamento)"
        }
        
        return texto
    }
    
    // MARK: Validacao e Gravacao
    
    var podeSalvar: Bool {
        guard (valor ?? 0) > 0 else {
            return false
        }
        
        if pontoDeParada != nil {
            return true
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
        var ponto: Ponto?
        
        if let daParada = pontoDeParada {
            ponto = daParada
        } else {
            switch modo {
            case .existente:
                ponto = pontoSelecionado
            case .novo:
                ponto = viagem.adicionarPonto(nome: novoNome,
                                              horario: data,
                                              odometro: novoOdometro ?? 0,
                                              coordenada: novaCoordenada,
                                              em: context)
            case .nenhum:
                break
            }
        }
        
        let litrosFinal = categoria == .combustivel ? litros : nil
        let precoFinal = categoria == .combustivel ? precoLitro : nil
        
        if let editando {
            viagem.atualizarDespesa(editando,
                                    categoria: categoria,
                                    valor: valor ?? 0,
                                    descricao: descricao,
                                    data: data,
                                    litros: litrosFinal,
                                    precoLitro: precoFinal,
                                    ponto: ponto,
                                    parada: paradaSelecionada)
        } else {
            viagem.adicionarDespesa(categoria: categoria,
                                    valor: valor ?? 0,
                                    descricao: descricao,
                                    data: data,
                                    litros: litrosFinal,
                                    precoLitro: precoFinal,
                                    ponto: ponto,
                                    parada: paradaSelecionada,
                                    em: context)
        }
        
    }
}
