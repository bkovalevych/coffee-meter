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
        case .ukrainian: return "Українська"
        case .english: return "English"
        }
    }
}

enum Currency: String, CaseIterable {
    case uah = "UAH"
    case usd = "USD"

    var displayName: String {
        switch self {
        case .uah: return "Гривня (₴)"
        case .usd: return "Долар ($)"
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

    var language: Language {
        get { Language(rawValue: languageRawValue) ?? .ukrainian }
        set { languageRawValue = newValue.rawValue }
    }

    var currency: Currency {
        get { Currency(rawValue: currencyRawValue) ?? .uah }
        set { currencyRawValue = newValue.rawValue }
    }

    static let shared = UserSettings()

    static let defaultBudget: Double = 1000.0

    func resetToDefaults() {
        monthlyBudget = UserSettings.defaultBudget
    }
}
