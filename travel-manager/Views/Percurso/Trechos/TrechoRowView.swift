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
        var partes: [String] = []
        
        partes.append(formatarDuracao(trecho.duracao) + " em movimento")
        
        if trecho.tempoParado >= 60 {
            partes.append("parado " + formatarDuracao(trecho.tempoParado))
        }
        
        if let v = trecho.velocidadeMedia {
            partes.append(v.velocidadeTexto)
        }
        
        return partes.joined(separator: " • ")
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
