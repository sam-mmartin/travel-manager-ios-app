//
//  Kilometragem.swift
//  travel-manager
//
//  Created by Samuel on 19/10/26.
//

import SwiftUI
import SwiftData

struct KilometragemView: View {
    let viagem: Viagem
    
    private var consumoTexto: String {
        viagem.consumoMedio?.kmPorLitroTexto ?? "-"
    }
    
    private var custoKmTexto: String {
        guard let c = viagem.custoPorKm else { return "-" }
        return c.moeda + "/km"
    }
    
    var body: some View {
        List {
            Section("Resumo") {
                LabeledContent("Distância percorrida", value: viagem.kmPercorrido.kmTexto)
                LabeledContent("Consumo médio", value: consumoTexto)
                LabeledContent("Custo por km", value: custoKmTexto)
            }
            
            Section {
                LabeledContent("Odômetro inicial", value: viagem.odometroInicial.kmTexto)
                LabeledContent(viagem.chegou ? "Odômetro final" : "Odômetro atual",
                               value: viagem.odometroAtual.kmTexto)
            } header: {
                Text("Odômetro")
            } footer: {
                if !viagem.chegou {
                    Text("O odômetro atual é o maior valor registrado nos pontos. O final é informado ao registrar a chegada.")
            }
            }
        }
        .navigationTitle("Quilometragem")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    KilometragemView(viagem: Viagem(nome: "Brasilia", destino: "Lago Verde"))
}
