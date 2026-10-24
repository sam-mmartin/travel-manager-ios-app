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
    
    private var consumoTexto: String {
        trip.consumoMedio?.kmPorLitroTexto ?? "-"
    }
    
    private var custoKmTexto: String {
        guard let c = trip.custoPorKm else { return "-" }
        return c.moeda + "/km"
    }
    
    var body: some View {
        List {
            Section("Resumo") {
                LabeledContent("Distância percorrida", value: trip.kmPercorrido.kmTexto)
                LabeledContent("Consumo médio", value: consumoTexto)
                LabeledContent("Custo por km", value: custoKmTexto)
            }
            
            Section {
                LabeledContent("Odômetro inicial", value: trip.odometroInicial.kmTexto)
                LabeledContent(trip.chegou ? "Odômetro final" : "Odômetro atual",
                               value: trip.odometroAtual.kmTexto)
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
