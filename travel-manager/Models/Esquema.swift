//
//  Esquema.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import SwiftData

enum Esquema {
    static var modelos: [any PersistentModel.Type] {
        [Viagem.self, Despesa.self, Parada.self, Ponto.self]
    }
}
