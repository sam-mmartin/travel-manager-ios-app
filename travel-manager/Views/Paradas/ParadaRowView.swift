//
//  ParadaRowView.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import SwiftUI
import SwiftData

struct ParadaRowView: View {
    let parada: Parada
    
    private var titulo: String {
        parada.local.isEmpty ? "Parada" : parada.local
    }
    
    private var inicioTexto: String {
        parada.inicio.formatted(date: .abbreviated, time: .shortened)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(titulo)
            
            HStack {
                Text(inicioTexto)
                Spacer()
                
                if parada.fim == nil {
                    TimelineView(.periodic(from: .now, by: 30)) { _ in
                        Text("Em andamento - " + formatarDuracao(parada.duracao))
                    }
                } else {
                    Text(formatarDuracao(parada.duracao))
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            if !parada.motivo.isEmpty {
                Text(parada.motivo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
