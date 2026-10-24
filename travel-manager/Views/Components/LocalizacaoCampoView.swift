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
    var nomeSugerido: Binding<String>? = nil
    
    @State private var localizacao = LocalizacaoGPS()
    @State private var escolhendoNoMapa = false
    @State private var nomeAutomatico: String?
    @State private var tarefaNome: Task<Void, Never>?
    @State private var nomeVeioDaBusca = false
    
    // MARK: Textos
    
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
    
    // MARK: Nome do Local
    
    private func preencherNome(_ nome: String?) {
        guard let nomeSugerido,
              let nome else {
            return
        }
        
        let novo = nome.limpo
        guard !novo.isEmpty else {
            return
        }
        
        let atual = nomeSugerido.wrappedValue.limpo
        let veioDaBusca = atual == nomeAutomatico?.limpo
        
        if atual.isEmpty || veioDaBusca {
            nomeSugerido.wrappedValue = novo
            nomeAutomatico = novo
        }
    }
    
    private func buscarNome(para nova: Coordenada) {
        guard nomeSugerido != nil else {
            return
        }
        
        tarefaNome?.cancel()
        tarefaNome = Task {
            let nome = await NomeDoLocal.buscar(para: nova)
            guard !Task.isCancelled else {
                return
            }
            
            preencherNome(nome)
        }
    }
    
    private func coordenadaMudou(_ nova: Coordenada?) {
        if nomeVeioDaBusca {
            nomeVeioDaBusca = false
            return
        }
        
        guard let nova else {
            tarefaNome?.cancel()
            return
        }
        
        buscarNome(para: nova)
    }
    
    private func mapaConfirmou(_ nova: Coordenada, nome: String?) {
        if nome != nil && nova != coordenada {
            nomeVeioDaBusca = true
        }
        
        coordenada = nova
        preencherNome(nome)
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
    
    // MARK: Corpo
    
    // Atenção: modificadores como .sheet, .onChange e .task NÃO podem ficar no Group.
    // No Group, valem para cada filho (cada linha do Form) e se repetem.
    // Aqui, cada um fica em uma única view que sempre existe.
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
            .onChange(of: localizacao.estado) { _, novo in
                buscando.wrappedValue = (novo == .buscando)
                
                if case .obtido(let c) = novo {
                    coordenada = c
                }
            }
            .onChange(of: coordenada) { _, nova in
                coordenadaMudou(nova)
            }
            .task {
                if capturarAoAparecer && coordenada == nil {
                    localizacao.capturar()
                }
            }
            
            Button {
                escolhendoNoMapa = true
            } label: {
                Label("Escolher no mapa", systemImage: "map")
            }
            .disabled(localizacao.estado == .buscando)
            .sheet(isPresented: $escolhendoNoMapa) {
                SelecionarLocalView(coordenadaInicial: coordenada) { nova, nome in
                    mapaConfirmou(nova, nome: nome)
                }
            }
            
            statusView
            
            if coordenada != nil {
                Button(role: .destructive) {
                    coordenada = nil
                } label: {
                    Label("Remover localização", systemImage: "location.slash")
                }
            }
        }
    }
}
