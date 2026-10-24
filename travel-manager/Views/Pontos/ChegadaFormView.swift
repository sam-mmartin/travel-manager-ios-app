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
    @Environment(\.dismiss) private var dismiss
    
    @State private var horario = Date()
    @State private var odometro: Double?
    
    init(trip: Trip) {
        self.trip = trip
        _odometro = State(initialValue: trip.odometroAtual)
    }
    
    private var ultimoOdometro: Double {
        trip.pontosOrdenados.last? .odometro ?? trip.odometroInicial
    }
    
    private var ultimoHorario: Date {
        trip.pontosOrdenados.last?.horario ?? trip.inicio
    }
    
    private var mensagemErro: String? {
        if horario < ultimoHorario {
            return "O horário é anterior ao último ponto registrado."
        }
        
        guard let odo = odometro else { return nil }
        
        if odo < ultimoOdometro {
            return "O odômetro é menor que o do último ponto."
        }
        
        return nil
    }
    
    private var podeSalvar: Bool {
        odometro != nil && mensagemErro == nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Chegada em " + trip.destinoNome) {
                    DatePicker("Horário", selection: $horario)
                    TextField("Odômetro final (km)", value: $odometro, format: .number)
                        .keyboardType(.decimalPad)
                }
                
                if let erro = mensagemErro {
                    Text(erro)
                        .font(.footnote)
                        .foregroundStyle(.red)
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
                        trip.odometroFinal = odometro
                        trip.fim = horario
                        dismiss()
                    }
                    .disabled(!podeSalvar)
                }
            }
        }
    }
}
