//
//  DespesasListView.swift
//  travel-manager
//
//  Created by Samuel on 19/10/26.
//

import SwiftUI
import SwiftData

struct DespesasListView: View {
    let viagem: Viagem
    @Environment(\.modelContext) private var context
    @State private var novaDespesa = false
    
    private var ordenadas: [Despesa] {
        viagem.despesasOrdenadas
    }
    
    private var totalTexto: String {
        viagem.totalGasto.moeda
    }
    
    var body: some View {
        List {
            Section {
                LabeledContent("Total gasto", value: totalTexto)
            }
            
            Section("Todas as despeas") {
                ForEach(ordenadas) { d in
                    ExpenseRowView(despesa: d, consumo: viagem.consumo(de: d))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                context.delete(d)
                            } label : {
                                Label("Excluir", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .overlay {
            if ordenadas.isEmpty {
                ContentUnavailableView("Nenhuma despesa",
                systemImage: "creditcard",
                                       description: Text("Toque em + para registrar a primeira.")
                )
            }
        }
        .navigationTitle("Despesas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button { novaDespesa = true } label: {
                Label("Nova despesa", systemImage: "plus")
            }
        }
        .sheet(isPresented: $novaDespesa) {
            DespesaFormView(viagem: viagem)
        }
    }
}
