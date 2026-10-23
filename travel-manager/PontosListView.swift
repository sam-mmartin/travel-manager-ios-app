//
//  PontosListView.swift
//  travel-manager
//
//  Created by Samuel on 23/10/26.
//
import SwiftUI
import SwiftData

struct PontosListView: View {
    let trip: Trip
    @Environment(\.modelContext) private var context
    @State private var novoPonto = false
    
    var body: some View {
        List {
            Section {
                PontoRowView(nome: trip.origemNome,
                             horario: trip.inicio,
                             odometro: trip.odometroInicial,
                rotulo: "Partida")
                
                ForEach(trip.pontosOrdenados) { p in
                    PontoRowView(nome: p.nome,
                                 horario: p.horario,
                                 odometro: p.odometro)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            context.delete(p)
                        } label: {
                            Label("Excluir", systemImage: "trash")
                        }
                    }
                }
                
                if trip.chegou, let fim = trip.fim, let odo = trip.odometroFinal {
                    PontoRowView(nome: trip.destinoNome,
                                 horario: fim,
                                 odometro: odo,
                    rotulo: "Chegada")
                }
            } header: {
                Text("Todos os pontos")
            } footer: {
                Text("Partida e chegada fazem parte da viagem e não podem ser excluidas aqui.")
            }
        }
        .navigationTitle("Pontos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button { novoPonto = true } label: {
                Label("Novo ponto", systemImage: "plus")
            }
        }
        .sheet(isPresented: $novoPonto) {
            PontoFormView(trip: trip)
        }
    }
}
