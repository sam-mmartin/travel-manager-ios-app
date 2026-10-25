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
    
    init(viagem: Viagem, editando ponto: Ponto) {
        _estado = State(initialValue: PontoFormState(viagem: viagem,
                                                     editando: ponto))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
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
                } header: {
                    Text(estado.tituloSecao)
                } footer: {
                    if let texto = estado.referenciaOdometro {
                        Text(texto)
                    }
                }
                
                if estado.registro == .intermediario
                    && estado.paradaAberta != nil
                    && estado.editando == nil {
                    Section {
                        Toggle(isOn: Binding(
                            get: { estado.parada != nil},
                            set: { estado.parada = $0 ? estado.paradaAberta : nil }
                        )) {
                            Label("Vincular parada em andamento",
                            systemImage: "pause.circle")
                        }
                    } footer: {
                        Text("Associa este ponto à parada atual da viagem.")
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Viagem.self, Ponto.self, Parada.self, configurations: config)

    let viagem = Viagem(nome: "Origem", destino: "Destino")
    let parada = Parada(local: "Teste", motivo: "Teste")
    container.mainContext.insert(viagem)
    container.mainContext.insert(parada)
    
    parada.viagem = viagem
    
    return PontoFormView(viagem: viagem)
        .modelContainer(container)
}
