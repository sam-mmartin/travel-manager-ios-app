//
//  Parada.swift
//  travel-manager
//
//  Created by Samuel on 19/10/26.
//

import Foundation
import SwiftData

@Model
final class Parada {
    var inicio: Date = Date()
    var fim: Date?
    var local: String = ""
    var motivo: String = ""
    var trip: Trip?
    
    init(inicio: Date = .now, local: String = "", motivo: String = "") {
        self.inicio = inicio
        self.local = local
        self.motivo = motivo
    }
    
    var duracao: TimeInterval {
        (fim ?? Date()).timeIntervalSince(inicio)
    }
    
}

func formatarDuracao(_ intervalo: TimeInterval) -> String {
    if intervalo < 60 { return "menos de 1 min" }
    
    return Duration.seconds(intervalo)
        .formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
}
