//
//  ViagemEditView.swift
//  travel-manager
//
//  Created by Samuel on 25/10/26.
//
import SwiftUI

struct ViagemEditView: View {
    let viagem: Viagem
    @Environment(\.dismiss) private var dismiss
    
    @State private var nome: String
    @State private var destino: String
    
    init(viagem: Viagem) {
        self.viagem = viagem
        _nome = State(initialValue: viagem.nome)
        _destino = State(initialValue: viagem.destino)
    }
    
    private var podeSalvar: Bool {
        !nome.limpo.isEmpty && !destino.limpo.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Viagem") {
                    TextField("Nome da viagem", text: $nome)
                }
                
                Section {
                    LabeledContent("Origem", value: viagem.origemNome)
                    TextField("Local de destino", text: $destino)
                } header: {
                    Text("Percurso")
                } footer: {
                    Text("A origem é o ponto de partida. Para mudá-la, edite o ponto em Percuso > Ver todos os pontos. Se a chegada já foi registrada com o nome do destino, ela acompanha a mudança.")
                }
            }
            .navigationTitle("Editar viagem")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        viagem.atualizar(nome: nome, destino: destino)
                        dismiss()
                    }
                    .disabled(!podeSalvar)
                }
            }
        }
    }
}
