//
//  PontoFormState.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import Foundation
import SwiftData
import Observation

enum RegistroDePonto {
    case intermediario
    case chegada
}

@Observable
final class PontoFormState {
    let viagem: Viagem
    let registro: RegistroDePonto
    
    var nome: String
    var horario = Date()
    var odometro: Double?
    var coordenada: Coordenada?
    var buscandoGPS = false
    
    init(viagem: Viagem, registro: RegistroDePonto) {
        self.viagem = viagem
        self.registro = registro
        self.nome = registro == .chegada ? viagem.destinoNome : ""
        self.odometro = viagem.odometroAtual
    }
    
    // MARK: Textos
    
    var titulo: String {
        registro == .chegada ? "Registrar chegada" : "Novo ponto"
    }
    
    var tituloSecao: String {
        registro == .chegada ? "Chegada" : "Ponto"
    }
    
    var dicaNome: String {
        registro == .chegada ? "Local de chegada" : "Local (cidade, ponto, pedágio...)"
    }
    
    var dicaOdometro: String {
        registro == .chegada ? "Odômetro final (km)" : "Odômetro (km)"
    }
    
    var tituloGPS: String {
        registro == .chegada ? "Localização da chegada (opcional)" : "Localização (opcional)"
    }
    
    var capturarGPSAoAbrir: Bool {
        registro == .chegada
    }
    
    // MARK: Validacao
    
    var mensagemErro: String? {
        switch registro {
        case .intermediario:
            return viagem.erroDePonto(horario: horario, odometro: odometro)
        case .chegada:
            return viagem.erroDeChegada(horario: horario, odometro: odometro)
        }
    }
    
    var podeSalvar: Bool {
        !nome.limpo.isEmpty
        && odometro != nil
        && mensagemErro == nil
        && !buscandoGPS
    }
    
    // MARK: Gravacao
    
    func salvar(em context: ModelContext) {
        switch registro {
        case .intermediario:
            viagem.adicionarPonto(nome: nome,
                                  horario: horario,
                                  odometro: odometro ?? 0,
                                  coordenada: coordenada,
                                  em: context)
        case .chegada:
            viagem.registrarChegada(nome: nome,
                                    horario: horario,
                                    odometro: odometro ?? 0,
                                    coordenada: coordenada,
                                    em: context)
        }
    }
}
