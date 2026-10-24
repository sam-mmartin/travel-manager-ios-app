//
//  MapaPontosView.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import SwiftUI
import SwiftData
import MapKit

struct MarcadorPonto: Identifiable {
    let id: PersistentIdentifier
    let nome: String
    let coordenada: CLLocationCoordinate2D
    let tipo: TipoPonto
    
    var icone: String {
        switch tipo {
        case .partida: return "flag.fill"
        case .intermediario: return "mappin"
        case .chegada: return "flag.checkered"
        }
    }
    
    var cor: Color {
        switch tipo {
        case .partida: return .green
        case .intermediario: return .blue
        case .chegada: return .red
        }
    }
}

struct MapaPontosView: View {
    let trip: Trip
    
    @State private var posicao: MapCameraPosition = .automatic
    @State private var selecao: PersistentIdentifier?
    @State private var mostrarRota = true
    
    private var pontos: [Ponto] {
        trip.pontosComLocalizacao
    }
    
    private var marcadores: [MarcadorPonto] {
        var lista: [MarcadorPonto] = []
        
        for p in pontos {
            if let c = p.coordenada {
                lista.append(MarcadorPonto(id: p.persistentModelID,
                                           nome: p.nome,
                                           coordenada: c.clCoordinate,
                                           tipo: p.tipo))
            }
        }
        
        return lista
    }
    
    private var coordenadasRota: [CLLocationCoordinate2D] {
        marcadores.map {
            $0.coordenada
        }
    }
    
    private var pontoSelecionado: Ponto? {
        pontos.first {
            $0.persistentModelID == selecao
        }
    }
    
    private var desenharRota: Bool {
        mostrarRota && coordenadasRota.count >= 2
    }
    
    var body: some View {
        Group {
            if marcadores.isEmpty {
                ContentUnavailableView("Nenhum ponto no mapa",
                                       systemImage: "mappin.slash",
                                       description: Text("Registre um ponto usando a localização do iphone para vê-lo aqui."))
            } else {
                Map(position: $posicao, selection: $selecao) {
                    UserAnnotation()
                    
                    if desenharRota {
                        MapPolyline(coordinates: coordenadasRota)
                            .stroke(.blue, lineWidth: 3)
                    }
                    
                    ForEach(marcadores) { m in
                        Marker(m.nome,
                               systemImage: m.icone,
                               coordinate: m.coordenada)
                        .tint(m.cor)
                        .tag(m.id)
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                .safeAreaInset(edge: .bottom) {
                    if let ponto = pontoSelecionado {
                        PontoMapaCartaoView(ponto: ponto)
                    }
                }
            }
        }
        .navigationTitle("Mapa")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !marcadores.isEmpty {
                ToolbarItemGroup {
                    Button {
                        mostrarRota.toggle()
                    } label: {
                        Label("Linha do percurso",
                              systemImage: mostrarRota ? "point.topleft.down.curvedto.point.bottomright.up.fill"
                              : "point.topleft.down.curvedto.point.bottomright.up")
                    }
                    
                    Button {
                        selecao = nil
                        posicao = .automatic
                    } label: {
                        Label("Mostrar todos",
                              systemImage: "arrow.up.left.and.down.right.magnifyingglass")
                    }
                }
            }
        }
    }
}




