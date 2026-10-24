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
    
    @discardableResult
    func adicionarDespesa(categoria: Categoria, valor: Decimal,
                          descricao: String = "", data: Date = .now,
                          litros: Double? = nil, precoLitro: Decimal? = nil,
                          ponto: Ponto? = nil, parada: Parada? = nil,
                          em context: ModelContext) -> Despesa {
        var pontoFinal = ponto
        
        if let parada {
            if let pontoDaParada = parada.ponto {
                pontoFinal = pontoDaParada
            } else if let ponto {
                parada.definirPonto(ponto)
            }
        }
        
        let despesa = Despesa(categoria: categoria,
                              valor: valor,
                              descricao: descricao.limpo,
                              data: data,
                              litros: litros,
                              precoLitro: precoLitro)
        
        context.insert(despesa)
        despesa.viagem = self
        despesa.ponto = pontoFinal
        despesa.parada = parada
        
        return despesa
    }
}
