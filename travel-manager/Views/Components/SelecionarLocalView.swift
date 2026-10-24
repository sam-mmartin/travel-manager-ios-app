//
//  SelecionarLocalView.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import SwiftUI
import MapKit

struct SelecionarLocalView: View {
    var onConfirmar: (Coordenada, String?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var posicao: MapCameraPosition
    @State private var escolhida: Coordenada?
    @State private var nomeEscolhido: String?
    @State private var busca = ""
    @State private var resultados: [MKMapItem] = []
    @State private var buscando = false
    @State private var aviso: String?
    
    init(coordenadaInicial: Coordenada?,
         onConfirmar: @escaping (Coordenada, String?) -> Void) {
        self.onConfirmar = onConfirmar
        _escolhida = State(initialValue: coordenadaInicial)
        
        if let c = coordenadaInicial {
            let regiao = MKCoordinateRegion(
                center: c.clCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02,
                                       longitudeDelta: 0.02)
            )
            _posicao = State(initialValue: .region(regiao))
        } else {
            _posicao = State(initialValue: .userLocation(fallback: .automatic))
        }
    }
    
    // MARK: Textos
    
    private var coordenadaTexto: String {
        guard let c = escolhida else {
            return "Toque no mapa para marcar o local."
        }
        
        let lat = c.latitude.formatted(
            .number.precision(.fractionLength(5))
        )
        let lon = c.longitude.formatted(
            .number.precision(.fractionLength(5))
        )
        let coordenadas = lat + ", " + lon
        
        if let nome = nomeEscolhido {
            return nome + " • " + coordenadas
        }
        
        return coordenadas
    }
    
    // MARK: Busca
    
    private func pesquisar() async {
        let texto = busca.limpo
        guard !texto.isEmpty else {
            return
        }
        
        buscando = true
        aviso = nil
        defer { buscando = false }
        
        let pedido = MKLocalSearch.Request()
        pedido.naturalLanguageQuery = texto
        
        do {
            let resposta = try await MKLocalSearch(request: pedido).start()
            resultados = Array(resposta.mapItems.prefix(5))
            
            if resultados.isEmpty {
                aviso = "Nenhum resultado para essa busca."
            }
        } catch {
            resultados = []
            aviso = "Não foi possível buscar. Verifique a conexão."
        }
    }
    
    private func escolher(_ item: MKMapItem) {
        let c = item.location.coordinate
        escolhida = Coordenada(latitude: c.latitude, longitude: c.longitude)
        nomeEscolhido = item.name
        
        let regiao = MKCoordinateRegion(center: c,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01,
                                                               longitudeDelta: 0.01))
        posicao = .region(regiao)
        resultados = []
    }
    
    // MARK: Partes da tela
    
    @ViewBuilder
    private var painelBusca: some View {
        if buscando {
            ProgressView("Buscando...")
                .padding()
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
        } else if let aviso {
            Text(aviso)
                .font(.footnote)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
        } else if !resultados.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(resultados, id: \.self) { item in
                    Button {
                        escolher(item)
                    } label: {
                        Text(item.name ?? "Local sem nome")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Divider()
                }
            }
            .background(.regularMaterial)
        }
    }
    
    private var rodape: some View {
        Text(coordenadaTexto)
            .font(.footnote)
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial)
    }
    
    var body: some View {
        NavigationStack {
            MapReader { proxy in
                Map(position: $posicao) {
                    UserAnnotation()
                    
                    if let c = escolhida {
                        Marker("Local escolhido",
                               systemImage: "mappin",
                               coordinate: c.clCoordinate)
                        .tint(.red)
                    }
                }
                .onTapGesture(coordinateSpace: .local) { ponto in
                    if let c = proxy.convert(ponto, from: .local) {
                        escolhida = Coordenada(latitude: c.latitude,
                                               longitude: c.longitude)
                        nomeEscolhido = nil
                        resultados = []
                        aviso = nil
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .safeAreaInset(edge: .top) {
                painelBusca
            }
            .safeAreaInset(edge: .bottom) {
                rodape
            }
            .searchable(text: $busca, prompt: "Buscar lugar ou endereço")
            .onSubmit(of: .search) {
                Task { await pesquisar() }
            }
            .navigationTitle("Escolher no mapa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Usar") {
                        if let c = escolhida {
                            onConfirmar(c, nomeEscolhido)
                        }
                        
                        dismiss()
                    }
                    .disabled(escolhida == nil)
                }
            }
        }
    }
}
