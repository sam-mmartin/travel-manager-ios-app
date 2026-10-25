//
//  ParadaEditView.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import SwiftUI
import SwiftData

struct ParadaEditView: View {
    let parada: Parada
    @Environment(\.dismiss) private var dismiss
    
    @State private var local: String
    @State private var motivo: String
    @State private var inicio: Date
    @State private var encerrada: Bool
    @State private var fim: Date
    @State private var pontoID: PersistentIdentifier?
    
    init(parada: Parada) {
        self.parada = parada
        _local = State(initialValue: parada.local)
        _motivo = State(initialValue: parada.motivo)
        _inicio = State(initialValue: parada.inicio)
        _encerrada = State(initialValue: parada.fim != nil)
        _fim = State(initialValue: parada.fim ?? Date.now)
        _pontoID = State(initialValue: parada.ponto?.persistentModelID)
    }
    
    // MARK: Calculos
    
    private var pontos: [Ponto] {
        parada.viagem?.pontosDoPercurso ?? []
    }
    
    private func ponto(com id: PersistentIdentifier?) -> Ponto? {
        guard let id else {
            return nil
        }
        
        return pontos.first {
            $0.persistentModelID == id
        }
    }
    
    private var fimEfetivo: Date? {
        encerrada ? fim : nil
    }
    
    private var erro: String? {
        parada.viagem?.erroDeParada(inicio: inicio, fim: fimEfetivo)
    }
    
    private var duracaoTexto: String {
        let ate = fimEfetivo ?? Date.now
        
        return formatarDuracao(max(0, ate.timeIntervalSince(inicio)))
    }
    
    private func rotulo(_ p: Ponto) -> String {
        p.nome + " • " + p.odometro.kmTexto
    }
    
    private func salvar() {
        let novo = ponto(com: pontoID)
        
        if novo?.persistentModelID != parada.ponto?.persistentModelID {
            parada.definirPonto(novo)
        }
        
        parada.inicio = inicio
        parada.fim = fimEfetivo
        parada.motivo = motivo
        parada.local = local
        
        dismiss()
    }
    
    // MARK: Corpo
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Parada") {
                    TextField("Local", text: $local)
                    TextField("Motivo (almoço, descanso...)", text: $motivo)
                }
                
                Section {
                    DatePicker("Inicio", selection: $inicio)
                    
                    Toggle("Parada encerrada", isOn: $encerrada)
                    
                    if encerrada {
                        DatePicker("Fim", selection: $fim)
                    }
                    
                    LabeledContent("Duração", value: duracaoTexto)
                    
                    if let erro {
                        Text(erro)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Horários")
                } footer: {
                    if !encerrada {
                        Text("Parada em andamento. A duração conta até agora.")
                    }
                }
                
                Section {
                    Picker("Ponto", selection: $pontoID) {
                        Text("Nenhum").tag(PersistentIdentifier?.none)
                        
                        ForEach(pontos) { p in
                            Text(rotulo(p)).tag(Optional(p.persistentModelID))
                        }
                    }
                } header: {
                    Text("Local no percurso")
                } footer: {
                    Text("Ao escolher um ponto, as despesas desta parada passam para o mesmo ponto.")
                }
                
                if !parada.listaDespesas.isEmpty {
                    Section("Despesas desta parada") {
                        ForEach(parada.listaDespesas) { d in
                            HStack {
                                Label(d.descricao.isEmpty ? d.categoria.rawValue : d.descricao,
                                      systemImage: d.categoria.icone)
                                Spacer()
                                Text(d.valor.moeda)
                            }
                        }
                    }
                }
            }
            .onChange(of: encerrada) { _, ligada in
                if ligada {
                    fim = max(Date.now, inicio)
                }
            }
            .onChange(of: pontoID, { anterior, novo in
                local = Parada.localApos(trocarPara: ponto(com: novo),
                                         de: ponto(com: anterior),
                                         local: local)
            })
            .navigationTitle("Parada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") {
                        salvar()
                    }
                    .disabled(erro != nil)
                }
            }
        }
    }
}
