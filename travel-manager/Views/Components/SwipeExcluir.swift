//
//  SwipeExcluir.swift
//  travel-manager
//
//  Created by Samuel on 25/10/26.
//
import SwiftUI

extension View {
    /// Ação de excluir por deslize.
    /// - Com `confirmar`: o botão só pede a confirmação. Não usa o papel destrutivo,
    ///   porque ele recolhe a linha mesmo que o usuário cancele depois.
    /// - Sem `confirmar`: exclui na hora, com o papel destrutivo.
    func swipeExcluir(permitido: Bool = true,
                      confirmar: Bool,
                      pedir: @escaping () -> Void,
                      excluir: @escaping () -> Void) -> some View {
        swipeActions(edge: .trailing, allowsFullSwipe: !confirmar) {
            if permitido {
                if confirmar {
                    Button {
                        pedir()
                    } label: {
                        Label("Excluir", systemImage: "trash")
                    }
                    .tint(.red)
                } else {
                    Button(role: .destructive) {
                        excluir()
                    } label: {
                        Label("Excluir", systemImage: "trash")
                    }
                }
            }
        }
    }
}
