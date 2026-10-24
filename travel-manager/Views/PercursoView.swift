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
    @State private var novoPonto = false
    @State private var chegando = false
    
    private var statusTexto: String {
        trip.chegou ? "Concluída" : "Em andamento"
    }
    
    private var ultimoTrecho: Trecho? {
        trip.trechos.last
    }
    
    private var ultimoPonto: PontoPercurso? {
        trip.percurso.last
    }
    
    private var rotuloUltimoPonto: String? {
        if trip.chegou { return "Chegada" }
        if trip.pontosOrdenados.isEmpty {
            return "Partida"
        }
        
        return nil
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
            
            Section("Trechos") {
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
                                 rotulo: rotuloUltimoPonto)
                    
                }
                
                NavigationLink {
                    PontosListView(trip: trip)
                } label: {
                    Label("Ver todos os pontos", systemImage: "list.bullet")
                }
            }
            
            Section {
                if trip.chegou {
                    Button {
                        trip.fim = nil
                        trip.odometroFinal = nil
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
    }
}
