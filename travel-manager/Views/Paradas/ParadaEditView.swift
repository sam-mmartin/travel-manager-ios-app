//
//  ParadaEditView.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import SwiftUI
import SwiftData

struct ParadaEditView: View {
    @Bindable var parada: Parada
    @Environment(\.dismiss) private var dismiss
    
    private var pontos: [Ponto] {
        parada.viagem?.pontosDoPercurso ?? []
    }
    
    private var pontoID: Binding<PersistentIdentifier?> {
        Binding(
            get: { parada.ponto?.persistentModelID },
            set: { novo in
                let escolhido = pontos.first {
                    $0.persistentModelID == novo
                }
                parada.definirPonto(escolhido)
            }
        )
    }
    
    private var encerrada: Binding<Bool> {
        Binding(
            get: { parada.fim != nil },
            set: { parada.fim = $0 ? max(Date.now, parada.inicio) : nil }
        )
    }
    
    private var fim: Binding<Date> {
        Binding(
            get: { parada.fim ?? Date.now },
            set: { parada.fim = $0 }
        )
    }
    
    private var limiteInicio: PartialRangeThrough<Date> {
        ...(parada.fim ?? Date.now)
    }
    
    private var limiteFim: ClosedRange<Date> {
        let minimo = parada.inicio
        return minimo...max(minimo, Date.now)
    }
    
    private func rotulo(_ p: Ponto) -> String {
        p.nome + " • " + p.odometro.kmTexto
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Parada") {
                    TextField("Local", text: $parada.local)
                    TextField("Motivo (almoço, descanso...)", text: $parada.motivo)
                }
                
                Section {
                    DatePicker("Inicio",
                               selection: $parada.inicio,
                    in: limiteInicio)
                    
                    Toggle("Parada encerrada", isOn: encerrada)
                    
                    if parada.fim != nil {
                        DatePicker("Fim",
                        selection: fim,
                        in: limiteFim)
                    }
                    
                    LabeledContent("Duração",
                                   value: formatarDuracao(parada.duracao))
                } header: {
                    Text("Horários")
                } footer: {
                    if parada.fim == nil {
                        Text("Parada em andamento. A duração conta até agora.")
                    }
                }
                
                Section {
                    Picker("Ponto", selection: pontoID) {
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
            .navigationTitle("Parada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("OK") { dismiss() }
            }
        }
    }
}
