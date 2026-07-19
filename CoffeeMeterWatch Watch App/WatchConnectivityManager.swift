//
//  WatchConnectivityManager.swift
//  CoffeeMeterWatch Watch App
//
//  Created by Bohdan Kovalevych on 17.07.2026.
//

import Foundation
import WatchConnectivity
import Combine
import WidgetKit

/// Manages communication between Apple Watch and iPhone
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

    /// Request coffee data from iPhone (for simulator compatibility)
    func requestCoffeeDataFromPhone() {
        guard WCSession.default.isReachable else {
            print("⚠️ iPhone not reachable, cannot request coffee data")
            return
        }

        WCSession.default.sendMessage(["action": "requestCoffeeData"], replyHandler: nil) { error in
            print("❌ Failed to request coffee data from iPhone: \(error.localizedDescription)")
        }

        print("📱 Requested coffee data from iPhone")
    }

    /// Notify iPhone that a purchase was added (triggers context refresh)
    func notifyPurchaseAdded() {
        guard WCSession.default.activationState == .activated else {
            print("⚠️ WCSession not activated, purchase notification skipped")
            return
        }

        // Use transferUserInfo for reliable delivery even if iPhone isn't reachable
        WCSession.default.transferUserInfo(["action": "purchaseAdded"])
        print("✅ Notified iPhone about new purchase")
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

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("📨 Received message from iPhone: \(message.keys.joined(separator: ", "))")

        Task { @MainActor in
            // Handle coffee data sync
            if let prices = message["prices"] as? [String: Double] {
                print("💾 Received \(prices.count) coffee prices from iPhone")

                // Update predefined coffee prices
                for (rawValue, price) in prices {
                    if let type = PredefinedCoffeeType(rawValue: rawValue) {
                        CoffeeTypeManager.shared.updatePrice(for: type, to: Decimal(price))
                    }
                }
            }

            if let customCoffeesArray = message["customCoffees"] as? [[String: Any]] {
                print("💾 Received \(customCoffeesArray.count) custom coffees from iPhone")

                // Clear existing custom coffees and add received ones
                // First, get current custom coffees to remove them
                let currentCoffees = CoffeeTypeManager.shared.customCoffees
                for coffee in currentCoffees {
                    CoffeeTypeManager.shared.removeCustomCoffee(id: coffee.id)
                }

                // Add received custom coffees
                for coffeeDict in customCoffeesArray {
                    if let name = coffeeDict["name"] as? String,
                       let price = coffeeDict["price"] as? Double {
                        CoffeeTypeManager.shared.addCustomCoffee(name: name, price: Decimal(price))
                    }
                }

                print("✅ Coffee data sync complete")
            }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("📨 Received userInfo from iPhone: \(userInfo)")

        Task { @MainActor in
            if userInfo["action"] as? String == "purchaseAdded" {
                print("⌚ iPhone added a purchase, posting refresh notification...")
                NotificationCenter.default.post(name: .purchaseDataChanged, object: nil)

                // Refresh Watch widget immediately
                WidgetCenter.shared.reloadTimelines(ofKind: "CoffeeMeterWatchWidget")
            }
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let purchaseDataChanged = Notification.Name("purchaseDataChanged")
}
