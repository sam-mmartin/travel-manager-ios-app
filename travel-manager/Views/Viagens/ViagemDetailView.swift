//
//  ViagemDetailView.swift
//  travel-manager
//
//  Created by Samuel on 18/10/26.
//

import SwiftUI
import SwiftData

struct ViagemDetailView: View {
    let viagem: Viagem
    @Environment(\.modelContext) private var context
    @State private var novoPonto = false
    @State private var paradaEditando: Parada?
    @State private var editandoViagem = false
    
    private var categoriasComGasto: [Categoria] {
        Categoria.allCases.filter { viagem.total(de: $0) > 0 }
    }
    
    private var totalGastoTexto: String {
        viagem.totalGasto.moeda
    }
    
    var body: some View {
        List {
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup {
                Button("Editar") { editandoViagem = true }
                
                Button {
                    novoPonto = true
                } label: {
                    Label("Novo Ponto", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $editandoViagem) {
            ViagemEditView(viagem: viagem)
        }
        .sheet(isPresented: $novoPonto) { PontoFormView(viagem: viagem)}
        .sheet(item: $paradaEditando) { p in
            ParadaEditView(parada: p)
        }
    }
}

#Preview {
    ViagemDetailView(viagem: Viagem(nome: "Brasilia", destino: "Lago Verde"))
}
