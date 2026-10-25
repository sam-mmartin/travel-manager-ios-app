//
//  Viagem+Gastos.swift
//  travel-manager
//
//  Created by Samuel on 23/10/26.
//

import Foundation
import SwiftData

extension Viagem {
    var listaDespesas: [Despesa] { despesas ?? [] }
    
    var despesasOrdenadas: [Despesa] {
        listaDespesas.sorted {
            if $0.data != $1.data {
                return $0.data > $1.data
            }
            
            return $0.valor > $1.valor
        }
    }
    
    func despesasOrdenadas(de categoria: Categoria) -> [Despesa] {
        despesasOrdenadas.filter {
            $0.categoria == categoria
        }
    }
    
    var totalGasto: Decimal {
        var soma: Decimal = 0
        
        for d in listaDespesas {
            soma += d.valor
        }
        
        return soma
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
    
    private func pontoFinal(ponto: Ponto?, parada: Parada?) -> Ponto? {
        guard let parada else {
            return ponto
        }
        
        if let doPonto = parada.ponto {
            return doPonto
        }
        
        if let ponto {
            parada.definirPonto(ponto)
        }
        
        return ponto
    }
    
    @discardableResult
    func adicionarDespesa(categoria: Categoria, valor: Decimal,
                          descricao: String = "", data: Date = .now,
                          litros: Double? = nil, precoLitro: Decimal? = nil,
                          ponto: Ponto? = nil, parada: Parada? = nil,
                          em context: ModelContext) -> Despesa {
    
        let despesa = Despesa(categoria: categoria,
                              valor: valor,
                              descricao: descricao.limpo,
                              data: data,
                              litros: litros,
                              precoLitro: precoLitro)
        
        context.insert(despesa)
        despesa.viagem = self
        despesa.ponto = pontoFinal(ponto: ponto, parada: parada)
        despesa.parada = parada
        
        return despesa
    }
    
    func atualizarDespesa(_ despesa: Despesa, categoria: Categoria,
                          valor: Decimal, descricao: String,
                          data: Date, litros: Double?,
                          precoLitro: Decimal?, ponto: Ponto?,
                          parada: Parada?) {
        despesa.categoria = categoria
        despesa.valor = valor
        despesa.descricao = descricao.limpo
        despesa.data = data
        despesa.litros = litros
        despesa.precoLitro = precoLitro
        despesa.ponto = pontoFinal(ponto: ponto, parada: parada)
        despesa.parada = parada
    }
}
