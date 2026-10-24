//
//  CategoriaDespesasView.swift
//  travel-manager
//
//  Created by Samuel on 19/10/26.
//

import SwiftUI
import SwiftData

struct CategoriaDespesasView: View {
    let trip: Trip
    let categoria: Categoria
    
    @Environment(\.modelContext) private var context
    @State private var novaDespesa = false
    
    private var despesas: [Expense] {
        var lista: [Expense] = []
        
        for d in trip.listaDespesas {
            if d.categoria == categoria {
                lista.append(d)
            }
        }
        
        lista.sort {
            if $0.data != $1.data {
                return $0.data > $1.data
            }
            
            return $0.valor > $1.valor
        }
        
        return lista
    }
    
    private var totalTexto: String {
        trip.total(de: categoria).moeda
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
                    ExpenseRowView(despesa: d, consumo: trip.consumo(de: d))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                context.delete(d)
                            } label: {
                                Label("Excluir", systemImage: "trash")
                            }
                        }
                }
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
            ExpenseFormView(trip: trip, categoriaInicial: categoria)
            
        }
    }
}
