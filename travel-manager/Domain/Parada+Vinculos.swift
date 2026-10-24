//
//  Parada+Vinculos.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import Foundation

extension Parada {
    var listaDespesas: [Despesa] { despesas ?? [] }
    
    var emAndamento: Bool { fim == nil }
    
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
    
    func definirPonto(_ novo: Ponto?) {
        let anterior = ponto
        ponto = novo
        guard let novo else {
            return
        }
        
        for d in listaDespesas {
            d.ponto = novo
        }
        
        let localAtual = local.limpo
        let veioDoPontoAnterior = localAtual == anterior?.nome.limpo
        
        if localAtual.isEmpty || veioDoPontoAnterior {
            local = novo.nome
        }
    }
}
