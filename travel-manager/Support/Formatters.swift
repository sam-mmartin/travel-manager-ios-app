//
//  Formatters.swift
//  travel-manager
//
//  Created by Samuel on 23/10/26.
//
import Foundation

extension Decimal {
    var moeda: String {
        formatted(.currency(code: "BRL"))
    }
    
    func moedaCasas(_ casas: Int) -> String {
        formatted(.currency(code: "BRL")
            .precision(.fractionLength(casas)))
    }
}

extension Double {
    var kmTexto: String {
        formatted(.number.precision(
            .fractionLength(0...1))
        ) + " km"
    }
    
    var kmPorLitroTexto: String {
        formatted(.number.precision(
            .fractionLength(1)
        )) + " km/l"
    }
    
    var litrosTexto: String {
        formatted(.number.precision(
            .fractionLength(1)
        )) + " L"
    }
    
    var velocidadeTexto: String {
        formatted(.number.precision(
            .fractionLength(0)
        )) + " km/h"
    }
}

func formatarDuracao(_ intervalo: TimeInterval) -> String {
    if intervalo < 60 {
        return "menos de 1 min"
    }
    
    return Duration.seconds(intervalo)
        .formatted(.units(
            allowed: [.hours, .minutes],
            width: .abbreviated)
        )
}

extension String {
    var limpo: String {
        trimmingCharacters(in: .whitespaces)
    }
}
