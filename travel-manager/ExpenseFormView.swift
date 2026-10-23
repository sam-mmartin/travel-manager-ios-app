//
//  ExpenseFormView.swift
//  travel-manager
//
//  Created by Samuel on 22/10/26.
//
import SwiftUI
import SwiftData

enum ModoPonto: String, CaseIterable, Identifiable {
    case existente = "Existente"
    case novo = "Novo"
    case nenhum = "Nenhum"
    
    var id: String { rawValue }
}

struct ExpenseFormView: View {
    let trip: Trip
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var categoria: Categoria = .combustivel
    @State private var valor: Decimal?
    @State private var descricao = ""
    @State private var data = Date()
    @State private var litros: Double?
    @State private var precoLitro: Decimal?
    
    @State private var modo: ModoPonto = .novo
    @State private var pontoID: PersistentIdentifier?
    @State private var novoNome = ""
    @State private var novoOdometro: Double?
    
    init(trip: Trip, categoriaInicial: Categoria = .combustivel) {
        self.trip = trip
        _categoria = State(initialValue: categoriaInicial)
        
        let ultimo = trip.pontosOrdenados.last
        _modo = State(initialValue: ultimo == nil ? .novo : .existente)
        _pontoID = State(initialValue: ultimo?.persistentModelID)
        _novoOdometro = State(initialValue: trip.odometroAtual)
    }
    
    // MARK: Calculos de combustivel
    
    private var litrosCalculados: Double? {
        guard litros == nil,
              let valor = valor, let preco = precoLitro, preco > 0 else { return nil }
        
        return NSDecimalNumber(decimal: valor / preco).doubleValue
    }
    
    private var precoCalculado: Decimal? {
        guard precoLitro == nil,
              let valor = valor, valor > 0,
              let litros = litros, litros > 0 else { return nil }
        
        return valor / Decimal(litros)
    }
    
    private var textoLitrosEstimados: String? {
        guard let l = litrosCalculados else {return nil}
        let n = l.formatted(.number.precision(.fractionLength(2)))
        
        return "Litros estimados: " + n + " L"
    }
    
    private var textoPrecoEstimado: String? {
        guard let p = precoCalculado else { return nil}
        let n = p.formatted(.currency(code: "BRL").precision(.fractionLength(2)))
        
        return "Preço do litro estimado: " + n
    }
    
    // MARK: Ponto
    
    private var pontoSelecionado: Ponto? {
        guard let pontoID else { return nil }
        
        return trip.pontosOrdenados.first { $0.persistentModelID == pontoID }
    }
    
    private var erroNovoPonto: String? {
        guard modo == .novo else { return nil }
        
        return trip.erroDePonto(horario: data, odometro: novoOdometro)
    }
    
    private var novoPontoCompleto: Bool {
        let nomeOk = !novoNome.trimmingCharacters(in: .whitespaces).isEmpty
        
        return nomeOk && novoOdometro != nil
    }
    
    private var podeSalvar: Bool {
        guard (valor ?? 0) > 0 else { return false }
        
        switch modo {
        case .nenhum:
            return true
        case .existente:
            return pontoSelecionado != nil
        case .novo:
            return novoPontoCompleto && erroNovoPonto == nil
        }
    }
    
    private func rotulo(_ p: Ponto) -> String {
        let km = p.odometro.formatted(
            .number.precision(.fractionLength(0...1))
        )
        
        return p.nome + " - " + km + " km"
    }
    
    @ViewBuilder
    private var secaoPonto: some View {
        Picker("Ponto", selection: $modo) {
            ForEach(ModoPonto.allCases) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
        
        switch modo {
        case .existente:
            if trip.pontosOrdenados.isEmpty {
                Text("Nenhum ponto cadastrado. Use a opção Novo.")
                    .foregroundStyle(.secondary)
            } else {
                Picker("Escolher ponto", selection: $pontoID) {
                    ForEach(trip.pontosOrdenados) { p in
                        Text(rotulo(p))
                            .tag(Optional(p.persistentModelID))
                    }
                }
            }
        case .novo:
            TextField("Local (posto, cidade...", text: $novoNome)
            TextField("Odômetro (km)", value: $novoOdometro, format: .number)
                .keyboardType(.decimalPad)
            Text("O horário do ponto será a data da despesa.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            if let erro = erroNovoPonto {
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
    
    private func salvar() {
        let e = Expense(categoria: categoria,
                        valor: valor ?? 0,
                        descricao: descricao,
                        data: data,
                        litros: categoria == .combustivel ? litros : nil,
                        precoLitro: categoria == .combustivel ? precoLitro : nil)
        
        context.insert(e)
        e.trip = trip
        
        switch modo {
        case .existente:
            e.ponto = pontoSelecionado
        case .novo:
            let nome = novoNome.trimmingCharacters(in: .whitespaces)
            let p = Ponto(nome: nome,
                          horario: data,
                          odometro: novoOdometro ?? 0)
            context.insert(p)
            p.trip = trip
            e.ponto = p
        case .nenhum:
            break
        }
        
        dismiss()
    }
    
    // MARK: Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Despesa") {
                    Picker("Categoria", selection: $categoria) {
                        ForEach(Categoria.allCases) { Text($0.rawValue).tag($0) }
                    }
                    TextField("Valor (R$)", value: $valor, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("Descrição", text: $descricao)
                    DatePicker("Data", selection: $data)
                }
                
                if categoria == .combustivel {
                    Section("Combustível") {
                        TextField("Preço do litro (R$)", value: $precoLitro, format: .number)
                            .keyboardType(.decimalPad)
                        TextField("Litros (opcional se informar o preço)", value: $litros, format: .number)
                            .keyboardType(.decimalPad)
                        
                        if let texto = textoLitrosEstimados {
                            Text(texto)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let texto = textoPrecoEstimado {
                            Text(texto)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section("Local") {
                    secaoPonto
                }
                
            }
            .navigationTitle("Nova despesa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { salvar() }
                        .disabled(!podeSalvar)
                }
            }
        }
    }
}
