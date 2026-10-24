//
//  ViagemDetailView.swift
//  travel-manager
//
//  Created by Samuel on 18/10/26.
//

import SwiftUI
import SwiftData

struct ViagemDetailView: View {
    @Bindable var viagem: Viagem
    @Environment(\.modelContext) private var context
    @State private var novaDespesa = false
    @State private var paradaEditando: Parada?
    
    private var ultimaParada: Parada?  {
        viagem.listaParadas.max { $0.inicio < $1.inicio }
    }
    
    private var categoriasComGasto: [Categoria] {
        Categoria.allCases.filter { viagem.total(de: $0) > 0 }
    }
    
    private var totalGastoTexto: String {
        viagem.totalGasto.moeda
    }
    
    private func iniciarParada() {
        let p = Parada()
        context.insert(p)
        p.viagem = viagem
    }
    
    var body: some View {
        List {
            Section("Resumo") {
                LabeledContent("Total gasto", value: totalGastoTexto)
                
                ForEach(categoriasComGasto) {cat in
                    NavigationLink {
                        CategoriaDespesasView(viagem: viagem, categoria: cat)
                    } label: {
                        CategoriaTotalRowView(categoria: cat, total: viagem.total(de: cat))
                    }
                }
                
                NavigationLink {
                    DespesasListView(viagem: viagem)
                } label: {
                    Label("Ver todas as despesas", systemImage: "list.bullet")
                }
            }
            
            Section("Paradas") {
                if viagem.paradaAberta != nil {
                    Button {
                        viagem.encerrarParadaAberta()
                    } label: {
                        Label("Encerrar parada", systemImage: "stop.circle.fill")
                    }
                } else {
                    Button {
                        viagem.iniciarParada(em: context)
                    } label: {
                        Label("Iniciar parada", systemImage: "play.circle.fill")
                    }
                }
                
                if let ultima = viagem.ultimaParada {
                    ParadaRowView(parada: ultima)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            paradaEditando = ultima
                        }
                } else {
                    Text("Nenhuma parada registrada.")
                        .foregroundStyle(.secondary)
                }
                
                TempoParadoView(viagem: viagem)
                
                NavigationLink {
                    ParadasListView(viagem: viagem)
                } label: {
                    Label("Ver todas as paradas", systemImage: "list.bullet")
                }
            }
            
            Section {
                NavigationLink {
                    PercursoView(viagem: viagem)
                } label: {
                    Label("Percurso e trechos",
                          systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                }
            }

            Section {
                NavigationLink {
                    KilometragemView(viagem: viagem)
                } label: {
                    Label("Quilometragem", systemImage: "speedometer")
                }
            }
        }
        .navigationTitle(viagem.nome)
        .toolbar {
            Button { novaDespesa = true } label: {
                Label("Nova despesa", systemImage: "plus")
            }
        }
        .sheet(isPresented: $novaDespesa) { DespesaFormView(viagem: viagem)}
        .sheet(item: $paradaEditando) { p in
            ParadaEditView(parada: p)
        }
    }
}

#Preview {
    ViagemDetailView(viagem: Viagem(nome: "Brasilia", destino: "Lago Verde"))
}
