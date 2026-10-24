//
//  PontosListView.swift
//  travel-manager
//
//  Created by Samuel on 23/10/26.
//
import SwiftUI
import SwiftData

struct PontosListView: View {
    let viagem: Viagem
    @Environment(\.modelContext) private var context
    @State private var novoPonto = false
    
    var body: some View {
        List {
            Section {
                ForEach(viagem.pontosDoPercurso) { p in
                    NavigationLink {
                        PontoDetailView(ponto: p)
                    } label: {
                        PontoRowView(ponto: p)
                    }
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
            PontoFormView(viagem: viagem)
        }
    }
}
