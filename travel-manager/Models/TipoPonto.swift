//
//  TipoPonto.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import Foundation
import SwiftData

enum TipoPonto: String, Codable, CaseIterable {
    case partida
    case intermediario
    case chegada
    
    var rotulo: String? {
        switch self {
        case .partida: "Partida"
        case .intermediario: nil
        case .chegada: "Chegada"
        }
    }
}
