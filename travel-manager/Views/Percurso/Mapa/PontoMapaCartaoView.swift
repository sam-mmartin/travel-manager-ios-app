//
//  PontoMapaCartaoView.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import SwiftUI
import SwiftData

struct PontoMapaCartaoView: View {
    let ponto: Ponto
    
    private var rotulo: String? {
        ponto.tipo.rotulo
    }
    
    private var detalhe: String {
        let horario = ponto.horario.formatted(
            date: .abbreviated, time: .shortened
        )
        var texto = horario + " • " + ponto.odometro.kmTexto
        
        if let rotulo {
            texto = rotulo + " • " + texto
        }
        
        return texto
    }
    
    private var urlLocal: URL? {
        ponto.coordenada?.urlMapas(nome: ponto.nome, rota: false)
    }
    
    private var urlRota: URL? {
        ponto.coordenada?.urlMapas(nome: ponto.nome, rota: true)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ponto.nome)
                .font(.headline)
            Text(detalhe)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                if let url = urlLocal {
                    Link(destination: url) {
                        Label("Abrir no Mapas", systemImage: "map")
                    }
                }
                
                if let url = urlRota {
                    Link(destination: url) {
                        Label("Rota até aqui", systemImage: "car.fill")
                    }
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding()
    }
}
