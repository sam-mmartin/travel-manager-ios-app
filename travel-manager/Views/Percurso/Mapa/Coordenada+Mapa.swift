//
//  Coordenada.swift
//  travel-manager
//
//  Created by Samuel on 24/10/26.
//
import MapKit

extension Coordenada {
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func urlMapas(nome: String, rota: Bool) -> URL? {
        var componentes = URLComponents(string: "https://maps.apple.com/")
        let valor = "\(latitude),\(longitude)"
        
        if rota {
            componentes?.queryItems = [
                URLQueryItem(name: "daddr", value: valor),
                URLQueryItem(name: "dirflg", value: "d")
            ]
        } else {
            componentes?.queryItems = [
                URLQueryItem(name: "ll", value: valor),
                URLQueryItem(name: "q", value: nome)
            ]
        }
        
        return componentes?.url
    }
}
