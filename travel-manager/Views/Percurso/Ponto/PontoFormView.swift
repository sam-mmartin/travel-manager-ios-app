//
//  PontoFormView.swift
//  travel-manager
//
//  Created by Samuel on 22/10/26.
//
import SwiftUI
import SwiftData

struct PontoFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var estado: PontoFormState
    
    init(viagem: Viagem, registro: RegistroDePonto = .intermediario) {
        _estado = State(initialValue: PontoFormState(viagem: viagem,
                                                     registro: registro))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(estado.tituloSecao) {
                    TextField(estado.dicaNome, text: $estado.nome)
                    DatePicker("Horário", selection: $estado.horario)
                    TextField(estado.dicaOdometro,
                              value: $estado.odometro,
                              format: .number)
                        .keyboardType(.decimalPad)
                    
                    if let erro = estado.mensagemErro {
                        Text(erro)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                
                Section(estado.tituloGPS) {
                    LocalizacaoCampoView(coordenada: $estado.coordenada,
                                         capturarAoAparecer: estado.capturarGPSAoAbrir,
                                         buscando: $estado.buscandoGPS,
                                         nomeSugerido: $estado.nome
                    )
                }
            }
            .navigationTitle(estado.titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        estado.salvar(em: context)
                        dismiss()
                    }
                    .disabled(!estado.podeSalvar)
                }
            }
        }
    }
}
