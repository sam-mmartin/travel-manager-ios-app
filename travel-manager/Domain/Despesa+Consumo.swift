//
//  Despesa+Consumo.swift
//  travel-manager
//
//  Created by Samuel on 25/10/26.
//
import Foundation

extension Despesa {
    var participaDoConsumo: Bool {
        categoria == .combustivel && ponto != nil && litrosEfetivos != nil
    }
}
