//
//  PontoRowView.swift
//  travel-manager
//
//  Created by Samuel on 22/10/26.
//
import SwiftUI
import SwiftData

struct PontoRowView: View {
    let ponto: Ponto
    
    private var horarioTexto: String {
        let h = ponto.horario.formatted(date: .abbreviated,
                                        time: .shortened)
        
        if let rotulo = ponto.tipo.rotulo { return rotulo + " - " + h }
        
        return h
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(ponto.nome)
                    
                    if ponto.temLocalizacao {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
                Text(horarioTexto)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if ponto.tempoParada >= 60 {
                    Text("Parado " + formatarDuracao(ponto.tempoParada))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(ponto.odometro.kmTexto)
                .foregroundStyle(.secondary)
        }
    }
}
