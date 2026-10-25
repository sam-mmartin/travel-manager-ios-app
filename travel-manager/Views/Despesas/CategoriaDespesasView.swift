//
//  CategoriaDespesasView.swift
//  travel-manager
//
//  Created by Samuel on 19/10/26.
//

import SwiftUI
import SwiftData

struct CategoriaDespesasView: View {
    let viagem: Viagem
    let categoria: Categoria
    
    @Environment(\.modelContext) private var context
    @State private var novaDespesa = false
    @State private var despesaEditando: Despesa?
    @State private var despesaParaExcluir: Despesa?
    
    private var despesas: [Despesa] {
        viagem.despesasOrdenadas(de: categoria)
    }
    
    private var totalTexto: String {
        viagem.total(de: categoria).moeda
    }
    
    var body: some View {
        List {
            Section {
                LabeledContent {
                    Text(totalTexto)
                } label: {
                    Label("Total em " + categoria.rawValue, systemImage: categoria.icone)
                }
            }
            
            Section("Despesas") {
                ForEach(despesas) { d in
                    DespesaRowView(despesa: d, consumo: viagem.consumo(de: d))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            despesaEditando = d
                        }
                        .swipeExcluir(confirmar: d.participaDoConsumo,
                                      pedir: { despesaParaExcluir = d },
                                      excluir: { context.delete(d) })                }
            }
        }
        .overlay {
            if despesas.isEmpty {
                ContentUnavailableView("Nenhuma despesa",
                                       systemImage: categoria.icone,
                                       description: Text("Não há despesas nesta categoria."))
            }
        }
        .navigationTitle(categoria.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                novaDespesa = true
            } label: {
                Label("Nova despesa", systemImage: "plus")
            }
        }
        .sheet(isPresented: $novaDespesa) {
            DespesaFormView(viagem: viagem, categoriaInicial: categoria)
            
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
