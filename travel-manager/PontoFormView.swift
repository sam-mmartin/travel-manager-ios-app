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
    
    init(trip: Trip) {
        self.trip = trip
        // Sugere o odometro do ultimo ponto (ou o inicial da viagem)
        let sugestao = trip.pontosOrdenados.last?.odometro ?? trip.odometroInicial
        _odometro = State(initialValue: sugestao)
    }
    
    // Ponto imediatamente antes e depois do horario escolhido
    private var anterior: PontoPercurso?  {
        trip.percurso.last { $0.horario <= horario }
    }
    
    private var proximo: PontoPercurso? {
        trip.percurso.first { $0.horario > horario }
    }
    
    private var mensagemErro: String? {
        if horario < trip.inicio {
            return "O horário é anterior à partida da viagem."
        }
        
        guard let odo = odometro else { return nil }
        
        if let a = anterior, odo < a.odometro {
            return "O odômetro é menor que o de " + a.nome + "."
        }
        
        if let p = proximo, odo > p.odometro {
            return "O odômetro é maior que o de " + p.nome + ", que vem depois."
        }
        
        return nil
    }
    
    private var podeSalvar: Bool {
        let nomeOk = !nome.trimmingCharacters(in: .whitespaces).isEmpty
        
        return nomeOk && odometro != nil && mensagemErro == nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
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
            .navigationTitle("Novo ponto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        let p = Ponto(nome: nome,
                                      horario: horario,
                                      odometro: odometro ?? 0)
                        
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
