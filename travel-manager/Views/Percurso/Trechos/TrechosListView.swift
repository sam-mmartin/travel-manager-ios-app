//
//  TrechosListView.swift
//  travel-manager
//
//  Created by Samuel on 23/10/26.
//
import SwiftUI
import SwiftData

struct TrechosListView: View {
    let viagem: Viagem
    
    private var trechos: [Trecho] {
        viagem.trechos
    }
    
    var body: some View {
        List {
            Section("Total do percurso") {
                LabeledContent("Distância", value: viagem.percursoKm.kmTexto)
                LinhaTempoView(viagem: viagem,
                               titulo: "Tempo total",
                               valor: \.percursoDuracao)
                LinhaTempoView(viagem: viagem,
                               titulo: "Em movimento",
                               valor: \.tempoEmMovimento)
            }
            
            Section("Todos os trechos") {
                ForEach(trechos) { t in
                    TrechoRowView(trecho: t)
                }
            }
        }
        .overlay {
            if trechos.isEmpty {
                ContentUnavailableView("Nenhum trecho",
                systemImage: "point.topleft.down.to.point.bottomright.curvepath",
                description: Text("Os trechos aparecem quando há pelo menos dois pontos no percurso."))
            }
        }
        .navigationTitle("Trechos")
        .navigationBarTitleDisplayMode(.inline)
    }
}
