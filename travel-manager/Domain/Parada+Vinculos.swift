//
//  Parada+Vinculos.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import Foundation

extension Parada {
    var listaDespesas: [Despesa] { despesas ?? [] }
    static let horasParaAviso: Double = 6
    
    var emAndamento: Bool { fim == nil }
    
    var paradaLonga: Bool {
        emAndamento && duracao > Parada.horasParaAviso * 3600
    }
    
    var temVinculos: Bool {
        ponto != nil || !listaDespesas.isEmpty
    }
    
    var exigeConfirmacaoAoExcluir: Bool {
        temVinculos
    }
    
    var resumoDespesas: String {
        let n = listaDespesas.count
        
        return n == 1 ? "1 despesa" : "\(n) despesas"
    }
    
    var totalGasto: Decimal {
        var soma: Decimal = 0
        
        for d in listaDespesas {
            soma += d.valor
        }
        
        return soma
    }
    
    var titulo: String {
        let texto = local.limpo
        
        if !texto.isEmpty {
            return texto
        }
        
        if let nome = ponto?.nome.limpo, !nome.isEmpty {
            return nome
        }
        
        return "Parada"
    }
    
    var mensagemExclusao: String {
        var partes: [String] = []
        
        if let ponto {
            partes.append("Ela está ligada ao ponto \(ponto.nome), que perde esse tempo parado.")
        }
        
        let n = listaDespesas.count
        
        if n == 1 {
            partes.append("A despesa ligada a ela continua no app, mas fica sem parada.")
        } else if n > 1 {
            partes.append("As \(n) despesas ligadas a ela continuam no app, mas ficam sem parada.")
        }
        
        partes.append("O tempo parado da viagem diminui em " + formatarDuracao(duracao) + ".")
        
        return partes.joined(separator: " ")
    }
    
    static func localApos(trocarPara novo: Ponto?,
                          de anterior: Ponto?,
                          local atual: String) -> String {
        guard let novo else {
            return atual
        }
        
        let texto = atual.limpo
        
        if texto.isEmpty || texto == anterior?.nome.limpo {
            return novo.nome
        }
        
        return atual
    }
    
    func definirPonto(_ novo: Ponto?) {
        let anterior = ponto
        ponto = novo
        
        guard let novo else {
            return
        }
        
        for d in listaDespesas {
            d.ponto = novo
        }
        
        local = Parada.localApos(trocarPara: novo,
                                 de: anterior,
                                 local: local)
    }
}
