//
//  ConfirmarExclusao.swift
//  travel-manager
//
//  Created by Samuel on 25/10/26.
//
import SwiftUI
import SwiftData

struct ConfirmarExclusao<Item: PersistentModel>: ViewModifier {
    @Environment(\.modelContext) private var context
    @Binding var item: Item?
    
    let titulo: String
    let botao: String
    let mensagem: (Item) -> String
    
    private var apresentando: Binding<Bool> {
        Binding(
            get: { item != nil },
            set: { if !$0 { item = nil } }
        )
    }
    
    func body(content: Content) -> some View {
        content.confirmationDialog(titulo,
                                   isPresented: apresentando,
                                   titleVisibility: .visible,
                                   presenting: item) { alvo in
            Button(botao, role: .destructive) {
                context.delete(alvo)
            }
            
            Button("Cancelar", role: .cancel) { }
        } message: { alvo in
            Text(mensagem(alvo))
        }
    }
}

extension View {
    func confirmarExclusao<Item: PersistentModel>(
        de item: Binding<Item?>,
        titulo: String,
        botao: String,
        mensagem: @escaping (Item) -> String
    ) -> some View {
        modifier(ConfirmarExclusao(item: item,
                                   titulo: titulo,
                                   botao: botao,
                                   mensagem: mensagem))
    }
}
