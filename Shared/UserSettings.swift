//
//  UserSettings.swift
//  coffee meter
//
//  Created by Bohdan Kovalevych on 15.07.2026.
//

import SwiftUI

enum Language: String, CaseIterable {
    case ukrainian = "uk"
    case english = "en"

    var displayName: String {
        switch self {
        case .ukrainian: return "language.ukrainian".localized()
        case .english: return "language.english".localized()
        }
    }
}

enum Currency: String, CaseIterable {
    case uah = "UAH"
    case usd = "USD"

    var displayName: String {
        switch self {
        case .uah: return "currency.uah".localized()
        case .usd: return "currency.usd".localized()
        }
    }

    var symbol: String {
        switch self {
        case .uah: return "₴"
        case .usd: return "$"
        }
    }
}

@Observable
class UserSettings {
    @ObservationIgnored
    @AppStorage("selectedLanguage") var languageRawValue: String = Language.ukrainian.rawValue

    @ObservationIgnored
    @AppStorage("selectedCurrency") var currencyRawValue: String = Currency.uah.rawValue

    @ObservationIgnored
    @AppStorage("monthlyBudget") var monthlyBudget: Double = 1000.0

    // Tracked properties for triggering view updates
    var currentCurrency: Currency = .uah

    var language: Language {
        get { Language(rawValue: languageRawValue) ?? .ukrainian }
        set { languageRawValue = newValue.rawValue }
    }

    var currency: Currency {
        get { Currency(rawValue: currencyRawValue) ?? .uah }
        set {
            currencyRawValue = newValue.rawValue
            currentCurrency = newValue
        }
    }

    static let shared = UserSettings()

    static let defaultBudget: Double = 1000.0

    init() {
        // Initialize tracked currency from stored value
        self.currentCurrency = Currency(rawValue: currencyRawValue) ?? .uah
    }

    func resetToDefaults() {
        monthlyBudget = UserSettings.defaultBudget
    }
}
