//
//  Expense.swift
//  travel-manager
//
//  Created by Samuel on 18/10/26.
//

import Foundation
import SwiftData

enum Categoria: String, Codable, CaseIterable, Identifiable {
    case combustivel = "Combustível"
    case alimentacao = "Alimentação"
    case hotel = "Hotel"
    case pedagio = "Pedágio"
    case outros = "Outros"
    
    var id: String {rawValue}
    
    var icone: String {
        switch self {
        case .combustivel: "fuelpump.fill"
        case .alimentacao: "fork.knife"
        case .hotel: "bed.double.fill"
        case .pedagio: "road.lanes"
        case .outros: "ellipsis.circle.fill"
        }
    }
}

@Model
final class Expense {
    var categoria: Categoria = Categoria.outros
    var valor: Decimal = 0
    var descricao: String = ""
    var data: Date = Date()
    var litros: Double?
    var precoLitro: Decimal?
    var trip: Trip?
    var ponto: Ponto?
    
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
