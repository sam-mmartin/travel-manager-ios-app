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
                ForEach(trip.pontosDoPercurso) { p in
                    PontoRowView(nome: p.nome,
                                 horario: p.horario,
                                 odometro: p.odometro,
                                 rotulo: p.tipo.rotulo,
                                 temLocalizacao: p.temLocalizacao)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        if p.tipo == .intermediario {
                            Button(role: .destructive) {
                                context.delete(p)
                            } label: {
                                Label("Excluir", systemImage: "trash")
                            }
                        }
                    }
                }
            } header: {
                Text("Todos os pontos")
            } footer: {
                Text("Partida e chegada não podem ser excluidas aqui. Para desfazer a chegada, use Reabrir viagem.")
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
