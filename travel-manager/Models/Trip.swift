//
//  Trip.swift
//  travel-manager
//
//  Created by Samuel on 18/10/26.
//
import Foundation
import SwiftData

@Model
final class Trip {
    var nome: String = ""
    var destino: String = ""
    var criadaEm: Date = Date()
    
    @Relationship(deleteRule: .cascade, inverse: \Expense.trip)
    var despesas: [Expense]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Parada.trip)
    var paradas: [Parada]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Ponto.trip)
    var pontos: [Ponto]? = []
    
    init(nome: String, destino: String = "") {
        self.nome = nome
        self.destino = destino
    }
}
