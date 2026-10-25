//
//  ContentView.swift
//  travel-manager
//
//  Created by Samuel on 18/10/26.
//

import SwiftUI
import SwiftData

struct ViagensListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Viagem.criadaEm, order: .reverse) private var viagens: [Viagem]
    @State private var criando = false
    @State private var viagemParaExcluir: Viagem?
    
    private var confirmandoExclusao: Binding<Bool> {
        Binding(
            get: { viagemParaExcluir != nil },
            set: { if !$0 { viagemParaExcluir = nil } }
        )
    }
 
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
                    .swipeExcluir(confirmar: true,
                                  pedir: { viagemParaExcluir = viagem },
                                  excluir: { context.delete(viagem) })
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
            .navigationDestination(for: Viagem.self) {
                ViagemDetailView(viagem: $0)
            }
            .toolbar {
                Button { criando = true} label: {
                    Label("Nova viagem", systemImage: "plus")
                }
            }
            .sheet(isPresented: $criando) {
                NovaViagemView()
            }
            .confirmationDialog("Excluir esta viagem?",
                                isPresented: confirmandoExclusao,
                                titleVisibility: .visible,
                                presenting: viagemParaExcluir) { viagem in
                Button("Excluir viagem e todos os dados", role: .destructive) {
                    context.delete(viagem)
                }
                Button("Cancelar", role: .cancel) { }
            } message: { viagem in
                Text("Pontos, despesas e paradas de \"" + viagem.nome + "\" serão apagados. Não é possível desfazer.")
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Viagem.self, configurations: config)

    let viagens = [
        Viagem(nome: "Road trip SP → RJ"),
        Viagem(nome: "Viagem para Floripa"),
    ]
    viagens.forEach { container.mainContext.insert($0) }

    return ViagensListView()
        .modelContainer(container)
}
