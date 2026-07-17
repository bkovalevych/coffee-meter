//
//  LocalizationManager.swift
//  coffee meter
//
//  Created by Bohdan Kovalevych on 15.07.2026.
//

import Foundation
import SwiftUI
import Combine

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguage: Language {
        didSet {
            UserSettings.shared.language = currentLanguage
        }
    }

    private var bundle: Bundle?

    private init() {
        self.currentLanguage = UserSettings.shared.language
        setupBundle()
    }

    private func setupBundle() {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            self.bundle = Bundle.main
            return
        }
        self.bundle = bundle
    }

    func setLanguage(_ language: Language) {
        currentLanguage = language
        setupBundle()
    }

    func localizedString(_ key: String, comment: String = "") -> String {
        return bundle?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }
}

// SwiftUI helper for localization
extension String {
    func localized() -> String {
        return LocalizationManager.shared.localizedString(self)
    }
}

// Environment key for localization updates
struct LocalizationKey: EnvironmentKey {
    static let defaultValue: LocalizationManager = LocalizationManager.shared
}

extension EnvironmentValues {
    var localization: LocalizationManager {
        get { self[LocalizationKey.self] }
        set { self[LocalizationKey.self] = newValue }
    }
}
