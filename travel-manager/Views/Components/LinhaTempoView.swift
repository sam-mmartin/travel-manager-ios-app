//
//  LinhaTempoView.swift
//  travel-manager
//
//  Created by Samuel on 25/10/26.
//
import SwiftUI

struct LinhaTempoView: View {
    let viagem: Viagem
    let titulo: String
    let valor: KeyPath<Viagem, TimeInterval>
    
    var body: some View {
        if viagem.paradaAberta != nil {
            TimelineView(.periodic(from: .now, by: 30)) { _ in
                linha
            }
        } else {
            linha
        }
    }
    
    private var linha: some View {
        LabeledContent(titulo,
                       value: formatarDuracao(viagem[keyPath: valor]))
    }
}
