//
//  CategoriaRowView.swift
//  travel-manager
//
//  Created by Samuel on 19/10/26.
//

import SwiftUI
import SwiftData

struct CategoriaTotalRowView: View {
    let categoria: Categoria
    let total: Decimal
    
    private var totalTexto: String {
        total.moeda
    }
    
    var body: some View {
        LabeledContent {
            Text(totalTexto)
        } label: {
            Label(categoria.rawValue, systemImage: categoria.icone)
        }
    }
}

#Preview {
    CategoriaTotalRowView(categoria: .combustivel, total: 100)
}
