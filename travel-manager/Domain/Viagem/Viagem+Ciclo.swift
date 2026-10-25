//
//  Viagem+Ciclo.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import Foundation
import SwiftData

extension Viagem {
    /// Cria a viagem ja com o ponto de partida
    @discardableResult
    static func criar(nome: String, origem: String, destino: String,
                      horario: Date, odometro: Double,
                      coordenada: Coordenada? = nil,
                      em context: ModelContext) -> Viagem {
        let viagem = Viagem(nome: nome.limpo, destino: destino.limpo)
        
        context.insert(viagem)
        
        viagem.inserirPonto(tipo: .partida,
                            nome: origem,
                            horario: horario,
                            odometro: odometro,
                            coordenada: coordenada,
                            em: context)
        
        return viagem
    }
    
    @discardableResult
    func adicionarPonto(nome: String, horario: Date, odometro: Double,
                        coordenada: Coordenada? = nil,
                        em context: ModelContext) -> Ponto {
        inserirPonto(tipo: .intermediario,
                     nome: nome,
                     horario: horario,
                     odometro: odometro,
                     coordenada: coordenada,
                     em: context)
    }
    
    /// Cria o ponto de chegada. Nao faz nada se a viagem ja terminou
    func registrarChegada(nome: String, horario: Date, odometro: Double,
                          coordenada: Coordenada? = nil,
                          em context: ModelContext) {
        guard pontoChegada == nil else {
            return
        }
        
        inserirPonto(tipo: .chegada,
                     nome: nome,
                     horario: horario,
                     odometro: odometro,
                     coordenada: coordenada,
                     em: context)
    }
    
    /// Remove o ponto de chegada. As despesas ligadas a ele ficam sem local.
    func reabrir(em context: ModelContext) {
        if let chegada = pontoChegada {
            context.delete(chegada)
        }
    }
    
    @discardableResult
    private func inserirPonto(tipo: TipoPonto, nome: String,
                              horario: Date, odometro: Double,
                              coordenada: Coordenada?,
                              em context: ModelContext) -> Ponto {
        let ponto = Ponto(nome: nome.limpo,
                          horario: horario,
                          odometro: odometro,
                          coordenada: coordenada,
                          tipo: tipo)
        
        context.insert(ponto)
        ponto.viagem = self
        
        return ponto
    }
}
