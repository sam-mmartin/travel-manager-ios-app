//
//  NewTripView.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import SwiftUI
import SwiftData

struct NewTripView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var nome = ""
    @State private var origem = ""
    @State private var destino = ""
    @State private var inicio = Date()
    @State private var odometro: Double?
    @State private var coordenada: Coordenada?
    @State private var buscandoGPS = false
    
    private var podeSalvar: Bool {
        let nomeOk = !nome.trimmingCharacters(in: .whitespaces).isEmpty
        let origemOk = !origem.trimmingCharacters(in: .whitespaces).isEmpty
        let destinoOk = !destino.trimmingCharacters(in: .whitespaces).isEmpty
        
        return nomeOk && origemOk && destinoOk
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Viagem") {
                    TextField("Nome da Viagem", text: $nome)
                }
                
                Section("Percurso") {
                    TextField("Local de origem", text: $origem)
                    TextField("Local de destino", text: $destino)
                }
                
                Section("Partida") {
                    DatePicker("Horário", selection: $inicio)
                    TextField("Odômetro inicial (km)", value: $odometro, format: .number)
                        .keyboardType(.decimalPad)
                }
                
                Section("Localização da partida") {
                    LocalizacaoCampoView(coordenada: $coordenada,
                                         capturarAoAparecer: true,
                                         buscando: $buscandoGPS)
                }
            }
            .navigationTitle("Nova viagem")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {dismiss()}
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        Trip.criar(nome: nome.trimmingCharacters(in: .whitespaces),
                                   origem: origem.trimmingCharacters(in: .whitespaces),
                                   destino: destino.trimmingCharacters(in: .whitespaces),
                                   horario: inicio,
                                   odometro: odometro ?? 0,
                                   coordenada: coordenada,
                                   em: context)
                        
                        dismiss()
                    }
                    .disabled(!podeSalvar || buscandoGPS)
                }
            }
        }
    }
}
