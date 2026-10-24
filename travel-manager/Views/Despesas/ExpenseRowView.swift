//
//  ExpenseRowView.swift
//  travel-manager
//
//  Created by Samuel on 22/10/26.
//
import SwiftUI
import SwiftData

struct ExpenseRow: View {
    let despesa: Expense
    let consumo: Double?
    
    private var titulo: String {
        despesa.descricao.isEmpty ? despesa.categoria.rawValue : despesa.descricao
    }
    
    private var valorTexto: String {
        despesa.valor.moeda
    }
    
    private var localTexto: String? {
        guard let ponto = despesa.ponto else { return nil }
        
        return ponto.nome + " - " + ponto.odometro.kmTexto
    }
    
    private var detalheCombustivel: String? {
        guard let litros = despesa.litrosEfetivos else { return nil }
        var texto = litros.litrosTexto
        
        if let preco = despesa.precoLitroEfetivo {
            texto += " - " + preco.moedaCasas(2) + "/L"
        }
        
        if let consumo {
            texto += " - " + consumo.kmPorLitroTexto
        }
        
        
        return texto
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Label(titulo, systemImage: despesa.categoria.icone)
                
                if let local = localTexto {
                    Label(local, systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if let detalhe = detalheCombustivel {
                    Text(detalhe)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(valorTexto)
        }
    }
}

#Preview {
    ExpenseRow(despesa: Expense(categoria: .hotel, valor: 100), consumo: 0)
}
