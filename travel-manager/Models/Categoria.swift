//
//  Categoria.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
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
