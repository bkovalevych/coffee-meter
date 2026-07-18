//
//  WatchConnectivityManager.swift
//  coffee meter
//
//  Created by Bohdan Kovalevych on 17.07.2026.
//

import Foundation
import WatchConnectivity
import Combine

/// Manages communication between iPhone and Apple Watch
/// Coffee data is shared via App Groups on real devices, but WatchConnectivity is used
/// as a fallback for iOS Simulator (where App Groups don't share between platforms)
@MainActor
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    private override init() {
        super.init()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    /// Send coffee data to Watch (for simulator compatibility)
    func syncCoffeeDataToWatch() {
        guard WCSession.default.isReachable else {
            print("⚠️ Watch not reachable, sync skipped")
            return
        }

        let manager = CoffeeTypeManager.shared

        // Prepare coffee data
        var coffeeData: [String: Any] = [:]

        // Add predefined coffee prices
        var prices: [String: Double] = [:]
        for type in PredefinedCoffeeType.allCases {
            let price = manager.price(for: type)
            prices[type.rawValue] = NSDecimalNumber(decimal: price).doubleValue
        }
        coffeeData["prices"] = prices

        // Add custom coffees
        let customCoffees = manager.customCoffees.map { coffee in
            [
                "id": coffee.id.uuidString,
                "name": coffee.name,
                "price": NSDecimalNumber(decimal: coffee.price).doubleValue
            ]
        }
        coffeeData["customCoffees"] = customCoffees

        WCSession.default.sendMessage(coffeeData, replyHandler: nil) { error in
            print("❌ Failed to sync coffee data to Watch: \(error.localizedDescription)")
        }

        print("✅ Synced coffee data to Watch: \(prices.count) prices, \(customCoffees.count) custom coffees")
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print("❌ WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("✅ WCSession activated with state: \(activationState.rawValue)")
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        print("⚠️ WCSession became inactive")
    }

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        print("⚠️ WCSession deactivated")
        session.activate()
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("📨 Received message from Watch: \(message.keys.joined(separator: ", "))")

        Task { @MainActor in
            if message["action"] as? String == "requestCoffeeData" {
                print("📱 Watch requested coffee data, sending sync...")
                syncCoffeeDataToWatch()
            }
        }
    }
}
