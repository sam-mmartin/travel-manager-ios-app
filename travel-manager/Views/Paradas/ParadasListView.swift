//
//  ParadasListView.swift
//  travel-manager
//
//  Created by Samuel on 19/10/26.
//

import SwiftUI
import SwiftData

struct ParadasListView: View {
    let viagem: Viagem
    @Environment(\.modelContext) private var context
    @State private var paradaEditando: Parada?
    
    private var ordenadas: [Parada] {
        viagem.paradasOrdenadas
    }
    
    var body: some View {
        List {
            Section {
                TempoParadoView(viagem: viagem, titulo: "Tempo parado total")
            }
            
            Section("Todas as paradas") {
                ForEach(ordenadas) { p in
                    ParadaRowView(parada: p)
                        .contentShape(Rectangle())
                        .onTapGesture { paradaEditando = p }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                context.delete(p)
                            } label: {
                                Label("Excluir", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .overlay {
            if ordenadas.isEmpty {
                ContentUnavailableView("Nenhuma parada", systemImage: "pause.circle", description: Text("As paradas registradas aparecerão aqui."))
            }
        }
        .navigationTitle("Paradas")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $paradaEditando) { p in
            ParadaEditView(parada: p)
        }
    }
}





