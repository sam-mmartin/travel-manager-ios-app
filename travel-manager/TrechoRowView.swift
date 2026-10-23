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
    
    private var kmTexto: String {
        trecho.km.formatted(
            .number.precision(.fractionLength(0...1))
        ) + " km"
    }
    
    private var detalhe: String {
        var texto = formatarDuracao(trecho.duracao)
        
        if let v = trecho.velocidadeMedia {
            texto += " - " + v.formatted(
                .number.precision(.fractionLength(0))
            ) + " km/h"
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
            Text(kmTexto)
        }
    }
}
