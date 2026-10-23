//
//  Ponto.swift
//  travel-manager
//
//  Created by Samuel on 22/10/26.
//
import Foundation
import SwiftData

@Model
final class Ponto {
    var nome: String = ""
    var horario: Date = Date()
    var odometro: Double = 0
    var trip: Trip?
    
    @Relationship(deleteRule: .nullify, inverse: \Expense.ponto)
    var despesas: [Expense]? = []
    
    init(nome: String, horario: Date = .now, odometro: Double) {
        self.nome = nome
        self.horario = horario
        self.odometro = odometro
    }
}

struct PontoPercurso {
    let nome: String
    let horario: Date
    let odometro: Double
}
