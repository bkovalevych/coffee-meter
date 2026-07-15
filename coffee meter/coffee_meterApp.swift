//
//  coffee_meterApp.swift
//  coffee meter
//
//  Created by Bohdan Kovalevych on 15.07.2026.
//

import SwiftUI
import SwiftData

@main
struct CoffeeMeterApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CoffeePurchase.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
