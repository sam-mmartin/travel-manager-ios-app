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
    let editando: Ponto?
    
    var nome: String
    var horario = Date()
    var odometro: Double?
    var coordenada: Coordenada?
    var buscandoGPS = false
    var parada: Parada? = nil
    
    init(viagem: Viagem, registro: RegistroDePonto) {
        self.viagem = viagem
        self.registro = registro
        self.editando = nil
        self.nome = registro == .chegada ? viagem.destinoNome : ""
        self.horario = Date()
        self.odometro = nil
    }
    
    init(viagem: Viagem, editando ponto: Ponto) {
        self.viagem = viagem
        self.registro = ponto.tipo == .chegada ? .chegada : .intermediario
        self.editando = ponto
        self.nome = ponto.nome
        self.horario = ponto.horario
        self.odometro = ponto.odometro
        self.coordenada = ponto.coordenada
    }
    
    var paradaAberta: Parada? {
        viagem.paradaAberta
    }
    
    // MARK: Textos
    
    var tipo: TipoPonto {
        if let editando {
            return editando.tipo
        }
        
        return registro == .chegada ? .chegada : .intermediario
    }
    
    var titulo: String {
        if editando != nil {
            return "Editar ponto"
        }
        
        return registro == .chegada ? "Registrar chegada" : "Novo ponto"
    }
    
    var tituloSecao: String {
        tipo.rotulo ?? "Ponto"
    }
    
    var dicaNome: String {
        switch tipo {
        case .partida: return "Local de partida"
        case .chegada: return "Local de chegada"
        case .intermediario: return "Local (cidade, ponto, pedágio...)"
        }
    }
    
    var dicaOdometro: String {
        switch tipo {
        case .partida: return "Odômetro inicial (km)"
        case .chegada: return "Odômetro final (km)"
        case .intermediario: return "Odômetro (km)"
        }
    }
    
    var referenciaOdometro: String? {
        guard editando == nil else {
            return nil
        }
        
        var anterior: Ponto?
        
        for p in viagem.pontosDoPercurso where p.horario <= horario {
            anterior = p
        }
        
        guard let anterior else {
            return nil
        }
        
        return "Anterior: \(anterior.nome) • \(anterior.odometro.kmTexto)"
    }
    
    var tituloGPS: String {
        if tipo == .intermediario {
            return "Localização (opcional)"
        }
        
        return "Localização da " + (tipo.rotulo ?? "").lowercased() + " (opcional)"
    }
    
    var capturarGPSAoAbrir: Bool {
        editando == nil && registro == .chegada
    }
    
    // MARK: Validacao
    
    var mensagemErro: String? {
        if let editando {
            return viagem.erroDeEdicao(de: editando,
                                       horario: horario,
                                       odometro: odometro)
        }
        
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
        if let editando {
            editando.atualizar(nome: nome,
                               horario: horario,
                               odometro: odometro ?? editando.odometro,
                               coordenada: coordenada)
            return
        }
        
        switch registro {
        case .intermediario:
            let ponto = viagem.adicionarPonto(nome: nome,
                                  horario: horario,
                                  odometro: odometro ?? 0,
                                  coordenada: coordenada,
                                  em: context)
            
            parada?.definirPonto(ponto)
        case .chegada:
            viagem.registrarChegada(nome: nome,
                                    horario: horario,
                                    odometro: odometro ?? 0,
                                    coordenada: coordenada,
                                    em: context)
        }
    }
}
