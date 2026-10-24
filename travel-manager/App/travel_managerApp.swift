//
//  travel_managerApp.swift
//  travel-manager
//
//  Created by Samuel on 18/10/26.
//

import SwiftUI
import SwiftData

@main
struct travel_managerApp: App {
    var body: some Scene {
        WindowGroup {
            ViagensListView()
        }
        .modelContainer(for: Esquema.modelos)
    }
}
