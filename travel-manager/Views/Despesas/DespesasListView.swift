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
    @State private var despesaEditando: Despesa?
    @State private var despesaParaExcluir: Despesa?
    
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
                    DespesaRowView(despesa: d, consumo: viagem.consumo(de: d))
                        .contentShape(Rectangle())
                        .onTapGesture { despesaEditando = d }
                        .swipeExcluir(confirmar: d.participaDoConsumo,
                                      pedir: { despesaParaExcluir = d },
                                      excluir: { context.delete(d) })
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
        .sheet(item: $despesaEditando) { d in
            DespesaFormView(viagem: viagem, editando: d)
        }
        .confirmarExclusao(de: $despesaParaExcluir,
                           titulo: "Excluir este abastecimento?",
                           botao: "Excluir abastecimento") { _ in
            "Este abastecimento entra no cálculo de consumo. O consumo médio será recalculado sem ele."
        }
    }
}
