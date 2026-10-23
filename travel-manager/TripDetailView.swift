//
//  TripDetailView.swift
//  travel-manager
//
//  Created by Samuel on 18/10/26.
//

import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Bindable var trip: Trip
    @Environment(\.modelContext) private var context
    @State private var novaDespesa = false
    @State private var paradaEditando: Parada?
    
    private var ultimaParada: Parada?  {
        trip.listaParadas.max { $0.inicio < $1.inicio }
    }
    
    private var categoriasComGasto: [Categoria] {
        Categoria.allCases.filter { trip.total(de: $0) > 0 }
    }
    
    private var totalGastoTexto: String {
        trip.totalGasto.formatted(.currency(code: "BRL"))
    }
    
    private var tempoParadoTexto: String {
        formatarDuracao(trip.tempoParado)
    }
    
    private func iniciarParada() {
        let p = Parada()
        context.insert(p)
        p.trip = trip
    }
    
    var body: some View {
        List {
            Section("Resumo") {
                LabeledContent("Total gasto", value: totalGastoTexto)
                
                ForEach(categoriasComGasto) {cat in
                    NavigationLink {
                        CategoriaDespesasView(trip: trip, categoria: cat)
                    } label: {
                        CategoriaTotalRowView(categoria: cat, total: trip.total(de: cat))
                    }
                }
                
                NavigationLink {
                    ExpensesListView(trip: trip)
                } label: {
                    Label("Ver todas as despesas", systemImage: "list.bullet")
                }
            }
            
            Section("Paradas") {
                if let aberta = trip.paradaAberta {
                    Button {
                        aberta.fim = .now
                    } label: {
                        Label("Encerrar parada", systemImage: "stop.circle.fill")
                    }
                } else {
                    Button {
                        iniciarParada()
                    } label: {
                        Label("Iniciar parada", systemImage: "play.circle.fill")
                    }
                }
                
                if let ultima = ultimaParada {
                    ParadaRow(parada: ultima)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            paradaEditando = ultima
                        }
                } else {
                    Text("Nenhuma parada registrada.")
                        .foregroundStyle(.secondary)
                }
                
                LabeledContent("Tempo parado", value: tempoParadoTexto)
                
                NavigationLink {
                    ParadasListView(trip: trip)
                } label: {
                    Label("Ver todas as paradas", systemImage: "list.bullet")
                }
            }
            
            Section {
                NavigationLink {
                    PercursoView(trip: trip)
                } label: {
                    Label("Percurso e trechos",
                          systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                }
            }

            Section {
                NavigationLink {
                    KilometragemView(trip: trip)
                } label: {
                    Label("Quilometragem", systemImage: "speedometer")
                }
            }            
        }
        .navigationTitle(trip.nome)
        .toolbar {
            Button { novaDespesa = true } label: {
                Label("Nova despesa", systemImage: "plus")
            }
        }
        .sheet(isPresented: $novaDespesa) { ExpenseFormView(trip: trip)}
        .sheet(item: $paradaEditando) { p in
            ParadaEditView(parada: p)
        }
    }
}

#Preview {
    TripDetailView(trip: Trip(nome: "Start", odometroInicial: 0))
}
