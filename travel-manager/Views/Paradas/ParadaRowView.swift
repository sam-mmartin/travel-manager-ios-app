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
        parada.titulo
    }
    
    private var inicioTexto: String {
        parada.inicio.formatted(date: .abbreviated, time: .shortened)
    }
    
    private var vinculoTexto: String? {
        var partes: [String] = []
        
        if let ponto = parada.ponto, ponto.nome.limpo != titulo.limpo {
            partes.append(ponto.nome)
        }
        
        let n = parada.listaDespesas.count
        
        if n > 0 {
            partes.append(n == 1 ? "1 despesa" : "\(n) despesas")
        }
        
        return partes.isEmpty ? nil : partes.joined(separator: " • ")
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
            
            if let texto = vinculoTexto {
                Label(texto, systemImage: "link")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !parada.motivo.isEmpty {
                Text(parada.motivo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
