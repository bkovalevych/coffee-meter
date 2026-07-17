//
//  CoffeeType.swift
//  coffee meter
//
//  Created by Bohdan Kovalevych on 17.07.2026.
//

import Foundation

/// Predefined coffee types with default prices
enum PredefinedCoffeeType: String, Codable, CaseIterable, Identifiable {
    case espresso
    case americano
    case latte
    case cappuccino

    var id: String { rawValue }

    /// Default price in UAH
    var defaultPrice: Decimal {
        switch self {
        case .espresso, .americano:
            return 60
        case .latte, .cappuccino:
            return 75
        }
    }

    /// Localized display name
    var displayName: String {
        "coffee.type.\(rawValue)".localized()
    }
}

/// User's configuration for a coffee type (custom price)
struct CoffeeTypeConfig: Codable, Equatable {
    let type: PredefinedCoffeeType
    var customPrice: Decimal?

    /// Current price (custom if set, otherwise default)
    var currentPrice: Decimal {
        customPrice ?? type.defaultPrice
    }

    init(type: PredefinedCoffeeType, customPrice: Decimal? = nil) {
        self.type = type
        self.customPrice = customPrice
    }
}
