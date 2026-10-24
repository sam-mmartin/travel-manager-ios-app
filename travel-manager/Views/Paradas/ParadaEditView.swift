//
//  ParadaEditView.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import SwiftUI
import SwiftData

struct ParadaEditView: View {
    @Bindable var parada: Parada
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Local", text: $parada.local)
                TextField("Motivo (almoço, descanso...)", text: $parada.motivo)
                DatePicker("Inicio", selection: $parada.inicio)
            }
            .navigationTitle("Parada")
            .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button("OK") { dismiss() }
                }
        }
    }
}
