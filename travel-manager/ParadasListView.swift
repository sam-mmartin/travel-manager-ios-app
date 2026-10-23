//
//  ParadasListView.swift
//  travel-manager
//
//  Created by Samuel on 19/10/26.
//

import SwiftUI
import SwiftData

struct ParadasListView: View {
    let trip: Trip
    @Environment(\.modelContext) private var context
    @State private var paradaEditando: Parada?
    
    private var ordenadas: [Parada] {
        trip.listaParadas.sorted {
            $0.inicio > $1.inicio
        }
    }
    
    private var tempoParadoTexto: String {
        formatarDuracao(trip.tempoParado)
    }
    
    var body: some View {
        List {
            Section {
                LabeledContent("Tempo parado total", value: tempoParadoTexto)
            }
            
            Section("Todas as paradas") {
                ForEach(ordenadas) { p in
                    ParadaRow(parada: p)
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


struct ParadaRow: View {
    let parada: Parada
    
    private var titulo: String {
        parada.local.isEmpty ? "Parada" : parada.local
    }
    
    private var inicioTexto: String {
        parada.inicio.formatted(date: .abbreviated, time: .shortened)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(titulo)
            
            HStack {
                Text(inicioTexto)
                Spacer()
                
                if parada.fim == nil {
                    TimelineView(.periodic(from: .now, by: 30)) { _ in
                        Text("Em andamento - " + formatarDuracao(parada.duracao))
                    }
                } else {
                    Text(formatarDuracao(parada.duracao))
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            if !parada.motivo.isEmpty {
                Text(parada.motivo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ParadaEditView: View {
    @Bindable var parada: Parada
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Local", text: $parada.local)
                TextField("Motivo (almoço, descanso...)", text: $parada.motivo)
                DatePicker("Inicio", selection: $parada.inicio)
            }
            .navigationTitle("Parada")
            .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button("OK") { dismiss() }
                }
        }
    }
}

