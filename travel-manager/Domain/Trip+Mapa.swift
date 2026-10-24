//
//  Trip+Mapa.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import Foundation

extension Trip {
    var pontosComLocalizacao: [Ponto] {
        pontosDoPercurso.filter {
            $0.temLocalizacao
        }
    }
}
