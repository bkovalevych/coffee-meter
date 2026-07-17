//
//  coffee_meterApp.swift
//  coffee meter
//
//  Created by Bohdan Kovalevych on 15.07.2026.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseCrashlytics

@main
struct CoffeeMeterApp: App {
    init() {
        // Initialize Firebase
        FirebaseApp.configure()

        // Initialize Watch Connectivity
        _ = WatchConnectivityManager.shared
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CoffeePurchase.self,
        ])

        let appGroupID = "group.useless.com.coffee-meter"
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            fatalError("App Group container not found. Check that App Groups entitlement is properly configured.")
        }

        let modelConfiguration = ModelConfiguration(
            url: containerURL.appendingPathComponent("CoffeeMeter.sqlite")
        )

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
