//
//  TrechoRowView.swift
//  travel-manager
//
//  Created by Samuel on 22/10/26.
//
import SwiftUI
import SwiftData

struct TrechoRowView: View {
    let trecho: Trecho
    
    private var titulo: String {
        trecho.origem.nome + " -> " + trecho.destino.nome
    }
    
    private var detalhe: String {
        var texto = formatarDuracao(trecho.duracao)
        
        if let v = trecho.velocidadeMedia {
            texto += " - " + v.velocidadeTexto
        }
        
        return texto
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                Text(detalhe)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(trecho.km.kmTexto)
        }
    }
}
