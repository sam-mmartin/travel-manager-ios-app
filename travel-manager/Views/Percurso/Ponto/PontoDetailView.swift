//
//  PontoDetailView.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import SwiftUI
import SwiftData

struct PontoDetailView: View {
    let ponto: Ponto
    
    private var horarioTexto: String {
        ponto.horario.formatted(date: .abbreviated,
                                time: .shortened)
    }
    
    private var urlMapas: URL? {
        ponto.coordenada?.urlMapas(nome: ponto.nome,
                                   rota: false)
    }
    
    var body: some View {
        List {
            Section("Ponto") {
                LabeledContent("Local", value: ponto.nome)
                LabeledContent("Horário", value: horarioTexto)
                LabeledContent("Odômetro", value: ponto.odometro.kmTexto)
                
                if let url = urlMapas {
                    Link(destination: url) {
                        Label("Abrir no Mapas", systemImage: "map")
                    }
                }
            }
            
            Section("Resumo") {
                LabeledContent("Tempo parado", value: formatarDuracao(ponto.tempoParada))
                LabeledContent("Total gasto", value: ponto.totalGasto.moeda)
            }
            
            Section("Paradas neste ponto") {
                if ponto.paradasOrdenadas.isEmpty {
                    Text("Nenhuma parada ligada a este ponto.")
                        .foregroundStyle(.secondary)
                }
                
                ForEach(ponto.paradasOrdenadas) { p in
                    ParadaRowView(parada: p)
                }
            }
            
            Section("Despesas neste ponto") {
                if ponto.despesasOrdenadas.isEmpty {
                    Text("Nenhuma despesa ligada a este ponto.")
                        .foregroundStyle(.secondary)
                }
                
                ForEach(ponto.despesasOrdenadas) { d in
                    HStack {
                        Label(d.descricao.isEmpty ? d.categoria.rawValue : d.descricao,
                              systemImage: d.categoria.icone)
                        Spacer()
                        Text(d.valor.moeda)
                    }
                }
            }
        }
        .navigationTitle(ponto.nome)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PontoDetailView(ponto: Ponto(nome: "Teste",
                                 horario: .now,
                                 odometro: 0,
                                 tipo: .intermediario))
}
