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
    var inicio: Date = Date()
    var fim: Date?
    var odometroInicial: Double = 0
    var odometroFinal: Double?
    var origem: String = ""
    var destino: String = ""
    
    @Relationship(deleteRule: .cascade, inverse: \Expense.trip)
    var despesas: [Expense]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Parada.trip)
    var paradas: [Parada]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Ponto.trip)
    var pontos: [Ponto]? = []
    
    init(nome: String, origem: String = "", destino: String = "",
         inicio: Date = .now, odometroInicial: Double = 0) {
        self.nome = nome
        self.origem = origem
        self.destino = destino
        self.inicio = inicio
        self.odometroInicial = odometroInicial
    }
}
