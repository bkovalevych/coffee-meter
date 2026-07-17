//
//  CoffeeTypeManager.swift
//  coffee meter
//
//  Created by Bohdan Kovalevych on 17.07.2026.
//

import Foundation
import Combine

/// Custom coffee drink defined by user
struct CustomCoffee: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var price: Decimal

    init(id: UUID = UUID(), name: String, price: Decimal) {
        self.id = id
        self.name = name
        self.price = price
    }
}

/// Manages coffee types and their user-customized prices
///
/// DATA SYNC ARCHITECTURE:
/// - On real devices: Uses App Groups for automatic data sharing between iPhone and Watch
/// - In iOS Simulator: App Groups don't share between platforms, so WatchConnectivity
///   is used as a fallback to sync data when the Watch app opens
@MainActor
class CoffeeTypeManager: ObservableObject {
    static let shared = CoffeeTypeManager()

    @Published private(set) var configs: [PredefinedCoffeeType: CoffeeTypeConfig]
    @Published private(set) var customCoffees: [CustomCoffee] = []

    let maxCustomCoffees = 5

    private let userDefaults = UserDefaults(suiteName: "group.useless.com.coffee-meter")
    private let configsKey = "coffeeTypeConfigs"
    private let customCoffeesKey = "customCoffees"

    private init() {
        // Verify App Group is accessible
        guard let userDefaults = userDefaults else {
            print("❌ CRITICAL: App Group 'group.useless.com.coffee-meter' is not accessible!")
            print("   Make sure App Groups entitlement is configured for this target")

            // Initialize with defaults
            self.configs = Dictionary(
                uniqueKeysWithValues: PredefinedCoffeeType.allCases.map { ($0, CoffeeTypeConfig(type: $0)) }
            )
            self.customCoffees = []
            return
        }

        // MIGRATION: Check if data exists in old location (regular UserDefaults) and migrate it
        let regularDefaults = UserDefaults.standard
        let needsMigration = userDefaults.data(forKey: configsKey) == nil &&
                             regularDefaults.data(forKey: configsKey) != nil

        if needsMigration {
            print("🔄 MIGRATION: Found data in old location, migrating to App Group...")

            // Migrate configs
            if let oldData = regularDefaults.data(forKey: configsKey) {
                userDefaults.set(oldData, forKey: configsKey)
                print("   ✅ Migrated coffee type configs")
            }

            // Migrate custom coffees
            if let oldData = regularDefaults.data(forKey: customCoffeesKey) {
                userDefaults.set(oldData, forKey: customCoffeesKey)
                print("   ✅ Migrated custom coffees")
            }

            userDefaults.synchronize()
            print("   ✅ Migration complete!")
        }

        // Load saved configs or initialize with defaults
        if let data = userDefaults.data(forKey: configsKey),
           let decoded = try? JSONDecoder().decode([String: CoffeeTypeConfig].self, from: data) {
            // Convert String keys back to enum
            self.configs = decoded.compactMapKeys { PredefinedCoffeeType(rawValue: $0) }
            print("✅ Loaded \(configs.count) coffee type configs from App Group")
        } else {
            // Initialize with defaults (no custom prices)
            self.configs = Dictionary(
                uniqueKeysWithValues: PredefinedCoffeeType.allCases.map { ($0, CoffeeTypeConfig(type: $0)) }
            )
            print("ℹ️ Initialized with default coffee type configs")
        }

        // Load saved custom coffees
        if let data = userDefaults.data(forKey: customCoffeesKey),
           let decoded = try? JSONDecoder().decode([CustomCoffee].self, from: data) {
            self.customCoffees = decoded
            print("✅ Loaded \(customCoffees.count) custom coffees from App Group:")
            for coffee in customCoffees {
                print("   - \(coffee.name): \(coffee.price)")
            }
        } else {
            print("ℹ️ No custom coffees found in App Group")
        }

        // Observe changes from other processes (e.g., iPhone updating while Watch is running)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserDefaultsChange),
            name: UserDefaults.didChangeNotification,
            object: userDefaults
        )
    }

    @objc private func handleUserDefaultsChange() {
        Task { @MainActor in
            reload()
        }
    }

    /// Manually refresh data from App Group storage
    func refresh() {
        reload()
    }

    /// Debug: Print what's currently in App Group storage
    func debugPrintAppGroupContents() {
        guard let userDefaults = userDefaults else {
            print("❌ DEBUG: App Group not accessible")
            return
        }

        // Print actual container URL
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.useless.com.coffee-meter") {
            print("📂 App Group container path: \(containerURL.path)")
        } else {
            print("❌ Could not get App Group container URL")
        }

        print("🔍 DEBUG: App Group contents:")

        // Check configs
        if let data = userDefaults.data(forKey: configsKey) {
            print("   ✅ Found configs data (\(data.count) bytes)")
            if let decoded = try? JSONDecoder().decode([String: CoffeeTypeConfig].self, from: data) {
                print("   ✅ Decoded \(decoded.count) configs")
            } else {
                print("   ❌ Failed to decode configs")
            }
        } else {
            print("   ℹ️ No configs data in App Group")
        }

        // Check custom coffees
        if let data = userDefaults.data(forKey: customCoffeesKey) {
            print("   ✅ Found custom coffees data (\(data.count) bytes)")
            if let decoded = try? JSONDecoder().decode([CustomCoffee].self, from: data) {
                print("   ✅ Decoded \(decoded.count) custom coffees:")
                for coffee in decoded {
                    print("      - \(coffee.name): \(coffee.price)")
                }
            } else {
                print("   ❌ Failed to decode custom coffees")
            }
        } else {
            print("   ℹ️ No custom coffees data in App Group")
        }

        // List all keys in App Group
        print("   📋 All keys in App Group:")
        let allKeys = userDefaults.dictionaryRepresentation().keys.sorted()
        for key in allKeys {
            print("      - \(key)")
        }
    }

    private func reload() {
        guard let userDefaults = userDefaults else {
            print("⚠️ Cannot reload: App Group not accessible")
            return
        }

        // Reload configs
        if let data = userDefaults.data(forKey: configsKey),
           let decoded = try? JSONDecoder().decode([String: CoffeeTypeConfig].self, from: data) {
            self.configs = decoded.compactMapKeys { PredefinedCoffeeType(rawValue: $0) }
            print("🔄 Reloaded \(configs.count) coffee configs")
        }

        // Reload custom coffees
        if let data = userDefaults.data(forKey: customCoffeesKey),
           let decoded = try? JSONDecoder().decode([CustomCoffee].self, from: data) {
            self.customCoffees = decoded
            print("🔄 Reloaded \(customCoffees.count) custom coffees:")
            for coffee in customCoffees {
                print("   - \(coffee.name): \(coffee.price)")
            }
        }
    }

    /// Get current price for a coffee type
    func price(for type: PredefinedCoffeeType) -> Decimal {
        configs[type]?.currentPrice ?? type.defaultPrice
    }

    /// Update custom price for a coffee type
    func updatePrice(for type: PredefinedCoffeeType, to newPrice: Decimal) {
        configs[type]?.customPrice = newPrice
        save()
    }

    /// Reset price to default for a coffee type
    func resetPrice(for type: PredefinedCoffeeType) {
        configs[type]?.customPrice = nil
        save()
    }

    /// Reset all prices to defaults
    func resetAllPrices() {
        for type in PredefinedCoffeeType.allCases {
            configs[type]?.customPrice = nil
        }
        save()
    }

    // MARK: - Custom Coffees

    var canAddCustomCoffee: Bool {
        customCoffees.count < maxCustomCoffees
    }

    /// Add a new custom coffee
    func addCustomCoffee(name: String, price: Decimal) {
        guard canAddCustomCoffee else { return }
        let newCoffee = CustomCoffee(name: name, price: price)
        customCoffees.append(newCoffee)
        saveCustomCoffees()
    }

    /// Remove a custom coffee by ID
    func removeCustomCoffee(id: UUID) {
        customCoffees.removeAll { $0.id == id }
        saveCustomCoffees()
    }

    /// Update a custom coffee
    func updateCustomCoffee(id: UUID, name: String, price: Decimal) {
        if let index = customCoffees.firstIndex(where: { $0.id == id }) {
            customCoffees[index].name = name
            customCoffees[index].price = price
            saveCustomCoffees()
        }
    }

    private func save() {
        guard let userDefaults = userDefaults else {
            print("❌ Cannot save configs: App Group not accessible")
            return
        }

        // Convert enum keys to String for encoding
        let encodable = configs.mapKeys { $0.rawValue }
        if let encoded = try? JSONEncoder().encode(encodable) {
            userDefaults.set(encoded, forKey: configsKey)
            userDefaults.synchronize() // Force immediate write
            print("✅ Saved \(configs.count) coffee configs to App Group")
        }
    }

    private func saveCustomCoffees() {
        guard let userDefaults = userDefaults else {
            print("❌ Cannot save custom coffees: App Group not accessible")
            return
        }

        if let encoded = try? JSONEncoder().encode(customCoffees) {
            userDefaults.set(encoded, forKey: customCoffeesKey)
            userDefaults.synchronize() // Force immediate write
            print("✅ Saved \(customCoffees.count) custom coffees to App Group:")
            for coffee in customCoffees {
                print("   - \(coffee.name): \(coffee.price)")
            }
        }
    }
}

// MARK: - Dictionary Extensions

private extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        Dictionary<T, Value>(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
    }

    func compactMapKeys<T: Hashable>(_ transform: (Key) -> T?) -> [T: Value] {
        Dictionary<T, Value>(uniqueKeysWithValues: compactMap { key, value in
            transform(key).map { ($0, value) }
        })
    }
}
