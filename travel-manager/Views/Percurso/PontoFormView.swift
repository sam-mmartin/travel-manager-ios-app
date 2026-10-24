//
//  PontoFormView.swift
//  travel-manager
//
//  Created by Samuel on 22/10/26.
//
import SwiftUI
import SwiftData

struct PontoFormView: View {
    let trip: Trip
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var nome = ""
    @State private var horario = Date()
    @State private var odometro: Double?
    @State private var coordenada: Coordenada?
    
    init(trip: Trip) {
        self.trip = trip
        _odometro = State(initialValue: trip.odometroAtual)
    }
    
    private var mensagemErro: String? {
        trip.erroDePonto(horario: horario, odometro: odometro)
    }
    
    private var podeSalvar: Bool {
        let nomeOk = !nome.trimmingCharacters(in: .whitespaces).isEmpty
        
        return nomeOk && odometro != nil && mensagemErro == nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Ponto") {
                    TextField("Local (cidade, posto, pedágio...)", text: $nome)
                    DatePicker("Horário", selection: $horario)
                    TextField("Odômetro (km)", value: $odometro, format: .number)
                        .keyboardType(.decimalPad)
                    
                    if let erro = mensagemErro {
                        Text(erro)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                
                Section("Localização (opcional)") {
                    LocalizacaoCampoView(coordenada: $coordenada)
                }
            }
            .navigationTitle("Novo ponto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        let nomeLimpo = nome.trimmingCharacters(in: .whitespaces)
                        let p = Ponto(nome: nomeLimpo,
                                      horario: horario,
                                      odometro: odometro ?? 0,
                                      coordenada: coordenada)
                        
                        context.insert(p)
                        p.trip = trip
                        dismiss()
                    }
                    .disabled(!podeSalvar)
                }
            }
        }
    }
}
