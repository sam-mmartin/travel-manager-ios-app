//
//  ContentView.swift
//  travel-manager
//
//  Created by Samuel on 18/10/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Trip.inicio, order: .reverse) private var viagens: [Trip]
    @State private var criando = false
 
    var body: some View {
        NavigationStack {
            List {
                ForEach(viagens) { viagem in
                    NavigationLink(value: viagem) {
                        VStack(alignment: .leading) {
                            Text(viagem.nome).font(.headline)
                            Text(viagem.totalGasto.moeda)
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    offsets.map { _ in viagens[0]}.forEach(context.delete)
                }
            }
            .overlay {
                if viagens.isEmpty {
                    ContentUnavailableView("Nenhuma viagem registrada.",
                    systemImage: "car.side",
                    description: Text("Toque em + para criar."))
                }
            }
            .navigationTitle("Minhas Viagens")
            .navigationDestination(for: Trip.self) {
                TripDetailView(trip: $0)
            }
            .toolbar {
                Button { criando = true} label: {
                    Label("Nova viagem", systemImage: "plus")
                }
            }
            .sheet(isPresented: $criando) {
                NewTripView()
            }
        }
    }
}
