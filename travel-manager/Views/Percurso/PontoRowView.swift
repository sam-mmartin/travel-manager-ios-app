//
//  PontoRowView.swift
//  travel-manager
//
//  Created by Samuel on 22/10/26.
//
import SwiftUI
import SwiftData

struct PontoRowView: View {
    let nome: String
    let horario: Date
    let odometro: Double
    var rotulo: String? = nil
    var temLocalizacao: Bool = false
    
    private var horarioTexto: String {
        let h = horario.formatted(date: .abbreviated, time: .shortened)
        
        if let rotulo { return rotulo + " - " + h }
        
        return h
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(nome)
                    
                    if temLocalizacao {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
                Text(horarioTexto)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(odometro.kmTexto)
                .foregroundStyle(.secondary)
        }
    }
}
