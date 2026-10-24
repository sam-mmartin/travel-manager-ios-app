//
//  Expense.swift
//  travel-manager
//
//  Created by Samuel on 18/10/26.
//

import Foundation
import SwiftData

@Model
final class Despesa {
    var categoria: Categoria = Categoria.outros
    var valor: Decimal = 0
    var descricao: String = ""
    var data: Date = Date()
    var litros: Double?
    var precoLitro: Decimal?
    var viagem: Viagem?
    var ponto: Ponto?
    var parada: Parada?
    
    var odometro: Double? { ponto?.odometro }
    
    init(categoria: Categoria, valor: Decimal, descricao: String = "",
         data: Date = .now, litros: Double? = nil, precoLitro: Decimal? = nil) {
        self.categoria = categoria
        self.valor = valor
        self.descricao = descricao
        self.data = data
        self.litros = litros
        self.precoLitro = precoLitro
    }
    
    var litrosEfetivos: Double? {
        if let litros, litros > 0 { return litros }
        guard categoria == .combustivel,
              let precoLitro, precoLitro > 0 else { return nil }
        
        return NSDecimalNumber(decimal: valor / precoLitro).doubleValue
    }
    
    var precoLitroEfetivo: Decimal? {
        if let precoLitro, precoLitro > 0 {return precoLitro}
        guard categoria == .combustivel,
              let litros, litros > 0, valor > 0 else { return nil }
        
        return valor / Decimal(litros)
    }
}
