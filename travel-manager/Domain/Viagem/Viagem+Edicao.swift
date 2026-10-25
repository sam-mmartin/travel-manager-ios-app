//
//  Viagem+Edicao.swift
//  travel-manager
//
//  Created by Samuel on 25/10/26.
//
import Foundation

extension Viagem {
    func atualizar (nome novoNome: String, destino novoDestino: String) {
        let destinoAntigo = destino.limpo
        let destinoNovo = novoDestino.limpo
        
        nome = novoNome.limpo
        destino = destinoNovo
        
        guard destinoAntigo != destinoNovo,
              let chegada = pontoChegada,
              chegada.nome.limpo == destinoAntigo else {
            return
        }
        
        chegada.atualizar(nome: destinoNovo,
                          horario: chegada.horario,
                          odometro: chegada.odometro,
                          coordenada: chegada.coordenada)
    }
    
    func erroDeParada(inicio: Date, fim: Date?) -> String? {
        let limite = Date.now.addingTimeInterval(60)
        
        if inicio < self.inicio {
            return "O inicio é anterior à partida da viagem."
        }
        
        if inicio > limite {
            return "O inico está no futuro."
        }
        
        if let fim {
            if fim < inicio {
                return "O fim é anterior ao inicio."
            }
            
            if fim > limite {
                return "O fim está no futuro."
            }
        }
        
        return nil
    }
}
