//
//  DespesaFormView.swift
//  travel-manager
//
//  Created by Samuel on 22/10/26.
//
import SwiftUI
import SwiftData



struct DespesaFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var estado: DespesaFormState
    
    init(viagem: Viagem, categoriaInicial: Categoria = .combustivel) {
        _estado = State(initialValue: DespesaFormState(
            viagem: viagem,
            categoriaInicial: categoriaInicial
        ))
    }
    
    init(viagem: Viagem, editando despesa: Despesa) {
        _estado = State(initialValue: DespesaFormState(
            viagem: viagem,
            editando: despesa
        ))
    }
    
    @ViewBuilder
    private var secaoParada: some View {
        if estado.viagem.paradasOrdenadas.isEmpty {
            Text("Nenhuma parada registrada. Inicie uma parada na tela de viagem.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        } else {
            Picker("Parada", selection: $estado.paradaID) {
                Text("Nenhuma").tag(PersistentIdentifier?.none)
                
                ForEach(estado.viagem.paradasOrdenadas) { p in
                    Text(estado.rotulo(p))
                        .tag(Optional(p.persistentModelID))
                }
            }
        }
    }
    
    @ViewBuilder
    private var secaoPonto: some View {
        if let ponto = estado.pontoDeParada {
            LabeledContent("Local da parada", value: estado.rotulo(ponto))
            Text("A despesa usa o ponto da parada escolhida.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        } else {
            seletorPonto
        }
    }
    
    @ViewBuilder
    private var seletorPonto: some View {
        Picker("Ponto", selection: $estado.modo) {
            ForEach(ModoPonto.allCases) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
        
        switch estado.modo {
        case .existente:
            if estado.viagem.pontosDoPercurso.isEmpty {
                Text("Nenhum ponto cadastrado. Use a opção Novo.")
                    .foregroundStyle(.secondary)
            } else {
                Picker("Escolher ponto", selection: $estado.pontoID) {
                    ForEach(estado.viagem.pontosDoPercurso) { p in
                        Text(estado.rotulo(p))
                            .tag(Optional(p.persistentModelID))
                    }
                }
            }
        case .novo:
            TextField("Local (posto, cidade...", text: $estado.novoNome)
            TextField("Odômetro (km)", value: $estado.novoOdometro, format: .number)
                .keyboardType(.decimalPad)
            LocalizacaoCampoView(coordenada: $estado.novaCoordenada,
                                 nomeSugerido: $estado.novoNome
            )
            Text("O horário do ponto será a data da despesa.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            if let erro = estado.erroNovoPonto {
                Text(erro)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        case .nenhum:
            Text("A despesa não ficará ligada a um local nem a um odômetro.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Despesa") {
                    Picker("Categoria", selection: $estado.categoria) {
                        ForEach(Categoria.allCases) { Text($0.rawValue).tag($0) }
                    }
                    TextField("Valor (R$)", value: $estado.valor, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("Descrição", text: $estado.descricao)
                    DatePicker("Data", selection: $estado.data)
                }
                
                if estado.categoria == .combustivel {
                    Section("Combustível") {
                        TextField("Preço do litro (R$)", value: $estado.precoLitro, format: .number)
                            .keyboardType(.decimalPad)
                        TextField("Litros (opcional se informar o preço)", value: $estado.litros, format: .number)
                            .keyboardType(.decimalPad)
                        
                        if let texto = estado.textoLitrosEstimados {
                            Text(texto)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let texto = estado.textoPrecoEstimado {
                            Text(texto)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section("Parada") {
                    secaoParada
                }
                
                Section("Local") {
                    secaoPonto
                }
                
            }
            .navigationTitle(estado.editando == nil ? "Nova despesa" : "Editar despesa")
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
