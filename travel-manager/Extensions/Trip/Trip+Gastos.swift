//
//  Trip+Gastos.swift
//  travel-manager
//
//  Created by Samuel on 23/10/26.
//

import Foundation

extension Trip {
    var listaDespesas: [Expense] { despesas ?? [] }
    
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
}
