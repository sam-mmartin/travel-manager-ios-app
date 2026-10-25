//
//  PontosListView.swift
//  travel-manager
//
//  Created by Samuel on 23/10/26.
//
import SwiftUI
import SwiftData

struct PontosListView: View {
    let viagem: Viagem
    @Environment(\.modelContext) private var context
    @State private var novoPonto = false
    @State private var pontoParaExcluir: Ponto?
    
    private var confirmando: Binding<Bool> {
        Binding(
            get: { pontoParaExcluir != nil },
            set: { if !$0 { pontoParaExcluir = nil } }
        )
    }
    
    var body: some View {
        List {
            Section {
                ForEach(viagem.pontosDoPercurso) { p in
                    NavigationLink {
                        PontoDetailView(ponto: p)
                    } label: {
                        PontoRowView(ponto: p)
                    }
                    .swipeExcluir(permitido: p.tipo == .intermediario,
                                  confirmar: p.temVinculos,
                                  pedir: { pontoParaExcluir = p },
                                  excluir: { context.delete(p) })
                }
            } header: {
                Text("Todos os pontos")
            } footer: {
                Text("Partida e chegada não podem ser excluidas aqui. Para desfazer a chegada, use Reabrir viagem.")
            }
        }
        .navigationTitle("Pontos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button { novoPonto = true } label: {
                Label("Novo ponto", systemImage: "plus")
            }
        }
        .sheet(isPresented: $novoPonto) {
            PontoFormView(viagem: viagem)
        }
        .confirmationDialog("Excluir este ponto?",
                            isPresented: confirmando,
                            titleVisibility: .visible,
                            presenting: pontoParaExcluir) { ponto in
            Button("Excluir ponto", role: .destructive) {
                context.delete(ponto)
            }
            Button("Cancelar", role: .cancel) { }
        } message: { ponto in
            Text("Este ponto tem " + ponto.resumoVinculos + ". Eles continuam no app, mas ficam sem este local e sem odômetro. O consumo médio pode mudar.")
        }
    }
}
