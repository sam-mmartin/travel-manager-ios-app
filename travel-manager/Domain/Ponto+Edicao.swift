//
//  Ponto+Edicao.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import Foundation

extension Ponto {
    func atualizar(nome novoNome: String, horario: Date, odometro: Double,
                   coordenada: Coordenada?) {
        let nomeAntigo = self.nome.limpo
        let nomeNovo = novoNome.limpo
        
        self.nome = nomeNovo
        self.horario = horario
        self.odometro = odometro
        self.coordenada = coordenada
        
        guard nomeAntigo != nomeNovo else { return }
        
        for p in listaParadas {
            if p.local.limpo == nomeAntigo {
                p.local = nomeNovo
            }
        }
    }
}
