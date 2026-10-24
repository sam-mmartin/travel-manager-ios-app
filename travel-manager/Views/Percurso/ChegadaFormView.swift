//
//  ChegadaFormView.swift
//  travel-manager
//
//  Created by Samuel on 22/10/26.
//
import SwiftUI
import SwiftData

struct ChegadaFormView: View {
    let trip: Trip
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var nome: String
    @State private var horario = Date()
    @State private var odometro: Double?
    @State private var coordenada: Coordenada?
    @State private var buscandoGPS = false
    
    init(trip: Trip) {
        self.trip = trip
        _nome = State(initialValue: trip.destino)
        _odometro = State(initialValue: trip.odometroAtual)
    }
    
    private var mensagemErro: String? {
        trip.erroDeChegada(horario: horario, odometro: odometro)
    }
    
    private var podeSalvar: Bool {
        let nomeOk = !nome.trimmingCharacters(in: .whitespaces).isEmpty
        return nomeOk && odometro != nil && mensagemErro == nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Chegada") {
                    TextField("Local de chegada", text: $nome)
                    DatePicker("Horário", selection: $horario)
                    TextField("Odômetro final (km)", value: $odometro, format: .number)
                        .keyboardType(.decimalPad)
    
                    if let erro = mensagemErro {
                        Text(erro)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                
                Section("Localização da chegada (opcional)") {
                    LocalizacaoCampoView(coordenada: $coordenada,
                                         capturarAoAparecer: true,
                                         buscando: $buscandoGPS)
                }
            }
            .navigationTitle("Registrar chegada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        trip.registrarChegada(nome: nome.trimmingCharacters(in: .whitespaces),
                                              horario: horario,
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
