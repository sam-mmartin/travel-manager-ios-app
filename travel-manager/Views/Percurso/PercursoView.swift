//
//  PercursoView.swift
//  travel-manager
//
//  Created by Samuel on 22/10/26.
//
import SwiftUI
import SwiftData

struct PercursoView: View {
    let viagem: Viagem
    @Environment(\.modelContext) private var context
    @State private var novoPonto = false
    @State private var chegando = false
    @State private var reabrindo = false
    
    private var statusTexto: String {
        viagem.chegou ? "Concluída" : "Em andamento"
    }
    
    private var ultimoTrecho: Trecho? {
        viagem.trechos.last
    }
    
    private var ultimoPonto: Ponto? {
        viagem.pontosDoPercurso.last
    }
    
    var body: some View {
        List {
            Section {
                LabeledContent("Rota", value: viagem.rotaTexto)
                LabeledContent("Situação", value: statusTexto)
                LabeledContent("Distância", value: viagem.percursoKm.kmTexto)
                LinhaTempoView(viagem: viagem,
                               titulo: "Tempo total",
                               valor: \.percursoDuracao)
                LinhaTempoView(viagem: viagem,
                               titulo: "Tempo parado",
                               valor: \.tempoParadoNoPercurso)
                LinhaTempoView(viagem: viagem,
                               titulo: "Em movimento",
                               valor: \.tempoEmMovimento)
            } header: {
                Text("Percurso Total")
            } footer: {
                if !viagem.chegou {
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
                    TrechosListView(viagem: viagem)
                } label: {
                    Label("Ver todos os trechos", systemImage: "list.bullet")
                }
            }
            
            Section("Ultimo Ponto") {
                if let ponto = ultimoPonto {
                    PontoRowView(ponto: ponto)
                    
                }
                
                NavigationLink {
                    PontosListView(viagem: viagem)
                } label: {
                    Label("Ver todos os pontos", systemImage: "list.bullet")
                }
                
                NavigationLink {
                    MapaPontosView(viagem: viagem)
                } label: {
                    Label("Ver pontos no mapa",
                          systemImage: "map")
                }
            }
            
            Section {
                if viagem.chegou {
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
                        Label("Registrar chegada em " + viagem.destinoNome,
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
            PontoFormView(viagem: viagem)
        }
        .sheet(isPresented: $chegando) {
            PontoFormView(viagem: viagem, registro: .chegada)
        }
        .confirmationDialog("Reabrir a viagem?", isPresented: $reabrindo, titleVisibility: .visible) {
            Button("Reabrir e remover a chegada", role: .destructive) {
                viagem.reabrir(em: context)
            }
            
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("O ponto de chegada será removido. Despesas ligadas a ele ficam sem local.")
        }
    }
}
