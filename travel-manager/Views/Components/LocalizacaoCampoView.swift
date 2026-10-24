//
//  LocalizacaoCampo.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import SwiftUI

struct LocalizacaoCampoView: View {
    @Binding var coordenada: Coordenada?
    var capturarAoAparecer = false
    var buscando: Binding<Bool> = .constant(false)
    @State private var localizacao = LocalizacaoGPS()
    
    private var coordenadaTexto: String? {
        guard let c = coordenada else {
            return nil
        }
        
        let lat = c.latitude.formatted(
            .number.precision(.fractionLength(5))
        )
        let lon = c.longitude.formatted(
            .number.precision(.fractionLength(5))
        )
        
        return lat + ", " + lon
    }
    
    private var tituloBotao: String {
        coordenada == nil ? "Usar minha localização" : "Atualizar localização"
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch localizacao.estado {
        case .buscando:
            HStack {
                ProgressView()
                Text("Obtendo localização...")
                    .foregroundStyle(.secondary)
            }
        case .negado:
            Text("Acesso à localização negado. Ative em Ajustes > Privacidade e Segurança > Serviços de Localização.")
                .font(.footnote)
                .foregroundStyle(.red)
        case .erro(let mensagem):
            Text("Não foi possível obter a localização: " + mensagem)
                .font(.footnote)
                .foregroundStyle(.red)
        default:
            EmptyView()
        }
    }
    
    var body: some View {
        Group {
            if let texto = coordenadaTexto {
                LabeledContent("Coordenadas", value: texto)
            }
            
            Button {
                localizacao.capturar()
            } label: {
                Label(tituloBotao, systemImage: "location.fill")
            }
            .disabled(localizacao.estado == .buscando)
            
            statusView
            
            if coordenada != nil {
                Button(role: .destructive) {
                    coordenada = nil
                } label: {
                    Label("Remover localização", systemImage: "location.slash")
                }
            }
        }
        .onChange(of: localizacao.estado) { _, novo in
            buscando.wrappedValue = (novo == .buscando)
            
            if case .obtido(let c) = novo {
                coordenada = c
            }
        }
        .task {
            if capturarAoAparecer && coordenada == nil {
                localizacao.capturar()
            }
        }
    }
}
