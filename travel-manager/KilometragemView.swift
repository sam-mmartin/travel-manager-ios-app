//
//  Kilometragem.swift
//  travel-manager
//
//  Created by Samuel on 19/10/26.
//

import SwiftUI
import SwiftData

struct KilometragemView: View {
    let trip: Trip
    
    private var kmTexto: String {
        let n = trip.kmPercorrido.formatted(
            .number.precision(.fractionLength(0...1)))
        
        return n + " km"
    }
    
    private var consumoTexto: String {
        guard let c = trip.consumoMedio else { return "-"}
        let n = c.formatted(.number.precision(.fractionLength(1)))
        
        return n + " km/l"
    }
    
    private var custoKmTexto: String {
        guard let c = trip.custoPorKm else { return "-" }
        return c.formatted(.currency(code: "BRL"))
    }
    
    private var odometroAtualTexto: String {
        trip.odometroAtual.formatted(
            .number.precision(.fractionLength(0...1))
        ) + " km"
    }
    
    private var odometroInicialTexto: String {
        trip.odometroInicial.formatted(
            .number.precision(.fractionLength(0...1))
        ) + " km"
    }
    
    var body: some View {
        List {
            Section("Resumo") {
                LabeledContent("Distância percorrida", value: kmTexto)
                LabeledContent("Consumo médio", value: consumoTexto)
                LabeledContent("Custo por km", value: custoKmTexto)
            }
            
            Section {
                LabeledContent("Odômetro inicial", value: odometroInicialTexto)
                LabeledContent(trip.chegou ? "Odômetro final" : "Odômetro atual",
                value: odometroAtualTexto)
            } header: {
                Text("Odômetro")
            } footer: {
                if !trip.chegou {
                    Text("O odômetro atual é o maior valor registrado em pontos e despesas. O final é informado ao registrar a chegada.")
            }
            }
        }
        .navigationTitle("Quilometragem")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    KilometragemView(trip: Trip(nome: "Teste", odometroInicial: 0))
}
