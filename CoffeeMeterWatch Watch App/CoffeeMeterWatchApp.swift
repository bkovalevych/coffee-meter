//
//  CoffeeMeterWatchApp.swift
//  CoffeeMeterWatch Watch App
//
//  Created by Bohdan Kovalevych on 17.07.2026.
//

import SwiftUI
import SwiftData

@main
struct CoffeeMeterWatch_Watch_AppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CoffeePurchase.self,
        ])

        let appGroupID = "group.useless.com.coffee-meter"
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!
        let modelConfiguration = ModelConfiguration(url: containerURL.appendingPathComponent("CoffeeMeter.sqlite"))

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
