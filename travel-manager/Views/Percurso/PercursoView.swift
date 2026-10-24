//
//  PercursoView.swift
//  travel-manager
//
//  Created by Samuel on 22/10/26.
//
import SwiftUI
import SwiftData

struct PercursoView: View {
    let trip: Trip
    @Environment(\.modelContext) private var context
    @State private var novoPonto = false
    @State private var chegando = false
    @State private var reabrindo = false
    
    private var statusTexto: String {
        trip.chegou ? "Concluída" : "Em andamento"
    }
    
    private var ultimoTrecho: Trecho? {
        trip.trechos.last
    }
    
    private var ultimoPonto: Ponto? {
        trip.pontosDoPercurso.last
    }
    
    var body: some View {
        List {
            Section {
                LabeledContent("Rota", value: trip.rotaTexto)
                LabeledContent("Situação", value: statusTexto)
                LabeledContent("Distância", value: trip.percursoKm.kmTexto)
                LabeledContent("Tempo", value: formatarDuracao(trip.percursoDuracao))
            } header: {
                Text("Percurso Total")
            } footer: {
                if !trip.chegou {
                    Text("Distância e tempo contados até o ultimo ponto registrado.")
                }
            }
            
            Section("Último trecho") {
                if let trecho = ultimoTrecho {
                    TrechoRowView(trecho: trecho)
                } else {
                    Text("Registre um ponto ou a chegada para formar um trecho.")
                        .foregroundStyle(.secondary)
                }
                
                NavigationLink {
                    TrechosListView(trip: trip)
                } label: {
                    Label("Ver todos os trechos", systemImage: "list.bullet")
                }
            }
            
            Section("Ultimo Ponto") {
                if let ponto = ultimoPonto {
                    PontoRowView(nome: ponto.nome,
                                 horario: ponto.horario,
                                 odometro: ponto.odometro,
                                 rotulo: ponto.tipo.rotulo,
                                 temLocalizacao: ponto.temLocalizacao)
                    
                }
                
                NavigationLink {
                    PontosListView(trip: trip)
                } label: {
                    Label("Ver todos os pontos", systemImage: "list.bullet")
                }
                
                NavigationLink {
                    MapaPontosView(trip: trip)
                } label: {
                    Label("Ver pontos no mapa",
                          systemImage: "map")
                }
            }
            
            Section {
                if trip.chegou {
                    Button {
                        reabrindo = true
                    } label: {
                        Label("Reabir viagem",
                              systemImage: "arrow.uturn.backward")
                    }
                } else {
                    Button {
                        chegando = true
                    } label: {
                        Label("Registrar chegada em " + trip.destinoNome,
                              systemImage: "flag.checkered")
                    }
                }
            }
        }
        .navigationTitle("Percurso")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                novoPonto = true
            } label: {
                Label("Novo ponto", systemImage: "plus")
            }
        }
        .sheet(isPresented: $novoPonto) {
            PontoFormView(trip: trip)
        }
        .sheet(isPresented: $chegando) {
            ChegadaFormView(trip: trip)
        }
        .confirmationDialog("Reabrir a viagem?", isPresented: $reabrindo, titleVisibility: .visible) {
            Button("Reabrir e remover a chegada", role: .destructive) {
                trip.reabrir(em: context)
            }
            
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("O ponto de chegada será removido. Despesas ligadas a ele ficam sem local.")
        }
    }
}
