//
//  ExpensesListView.swift
//  travel-manager
//
//  Created by Samuel on 19/10/26.
//

import SwiftUI
import SwiftData

struct ExpensesListView: View {
    let trip: Trip
    @Environment(\.modelContext) private var context
    @State private var novaDespesa = false
    
    private var ordenadas: [Expense] {
        trip.listaDespesas.sorted {
            if $0.data != $1.data {return $0.data > $1.data}
            
            return $0.valor > $1.valor
        }
    }
    
    private var totalTexto: String {
        trip.totalGasto.formatted(.currency(code: "BRL"))
    }
    
    var body: some View {
        List {
            Section {
                LabeledContent("Total gasto", value: totalTexto)
            }
            
            Section("Todas as despeas") {
                ForEach(ordenadas) { d in
                    ExpenseRow(despesa: d, consumo: trip.consumo(de: d))
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
            ExpenseFormView(trip: trip)
        }
    }
}
