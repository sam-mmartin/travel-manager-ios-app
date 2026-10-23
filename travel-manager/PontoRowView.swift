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
    
    private var horarioTexto: String {
        let h = horario.formatted(date: .abbreviated, time: .shortened)
        
        if let rotulo { return rotulo + " - " + h }
        
        return h
    }
    
    private var odometroTexto: String {
        odometro.formatted(
            .number.precision(.fractionLength(0...1))
        ) + " km"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(nome)
                Text(horarioTexto)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(odometroTexto)
                .foregroundStyle(.secondary)
        }
    }
}
