//
//  Viagem.swift
//  travel-manager
//
//  Created by Samuel on 18/10/26.
//
import Foundation
import SwiftData

@Model
final class Viagem {
    var nome: String = ""
    var destino: String = ""
    var criadaEm: Date = Date()
    
    @Relationship(deleteRule: .cascade, inverse: \Despesa.viagem)
    var despesas: [Despesa]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Parada.viagem)
    var paradas: [Parada]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Ponto.viagem)
    var pontos: [Ponto]? = []
    
    init(nome: String, destino: String = "") {
        self.nome = nome
        self.destino = destino
    }
}
