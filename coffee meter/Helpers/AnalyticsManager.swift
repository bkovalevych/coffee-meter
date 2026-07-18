//
//  AnalyticsManager.swift
//  coffee meter
//
//  Created by Bohdan Kovalevych on 17.07.2026.
//

import Foundation
import FirebaseAnalytics
import FirebaseCrashlytics

/// Centralized analytics and error tracking manager
struct AnalyticsManager {

    // MARK: - Events

    /// Track when user adds a coffee purchase
    static func logCoffeeAdded(amount: Decimal, source: PurchaseSource, note: String? = nil) {
        
        Analytics.logEvent("coffee_added", parameters: [
            "amount": NSDecimalNumber(decimal: amount).doubleValue,
            "source": source.rawValue,
            "has_note": note != nil
        ])

        Crashlytics.crashlytics().log("Coffee added: \(amount) from \(source.rawValue)")
        
    }

    /// Track when user views settings
    static func logSettingsOpened() {
        
        Analytics.logEvent("settings_opened", parameters: [:])
        
    }

    /// Track when user changes settings
    static func logSettingChanged(setting: String, value: String) {
        
        Analytics.logEvent("setting_changed", parameters: [
            "setting": setting,
            "value": value
        ])
        
    }

    /// Track when user exceeds budget
    static func logBudgetExceeded(amountOver: Double) {
        
        Analytics.logEvent("budget_exceeded", parameters: [
            "amount_over": amountOver
        ])

        Crashlytics.crashlytics().log("Budget exceeded by \(amountOver)")
        
    }

    /// Track when user views chart
    static func logChartOpened() {
        
        Analytics.logEvent("chart_opened", parameters: [:])
        
    }

    /// Track widget interaction
    static func logWidgetInteraction(widgetType: String) {
        
        Analytics.logEvent("widget_interaction", parameters: [
            "widget_type": widgetType
        ])
        
    }

    // MARK: - Errors

    /// Record non-fatal error
    static func logError(_ error: Error, context: String) {
        
        Crashlytics.crashlytics().record(error: error)
        Crashlytics.crashlytics().log("Error in \(context): \(error.localizedDescription)")

        Analytics.logEvent("error_occurred", parameters: [
            "context": context,
            "error": error.localizedDescription
        ])
        
    }

    /// Record custom error message
    static func logErrorMessage(_ message: String, context: String) {
        
        Crashlytics.crashlytics().log("Error in \(context): \(message)")

        Analytics.logEvent("error_occurred", parameters: [
            "context": context,
            "message": message
        ])
        
    }

    // MARK: - User Properties

    /// Set user properties for better crash analysis
    static func setUserProperties(currency: Currency, language: Language, monthlyBudget: Double) {
        
        Crashlytics.crashlytics().setCustomValue(currency.rawValue, forKey: "currency")
        Crashlytics.crashlytics().setCustomValue(language.rawValue, forKey: "language")
        Crashlytics.crashlytics().setCustomValue(monthlyBudget, forKey: "monthly_budget")

        Analytics.setUserProperty(currency.rawValue, forName: "currency")
        Analytics.setUserProperty(language.rawValue, forName: "language")
        
    }

    /// Update spending context for crash reports
    static func updateSpendingContext(monthlyTotal: Double, budgetRemaining: Double) {
        
        Crashlytics.crashlytics().setCustomValue(monthlyTotal, forKey: "monthly_total")
        Crashlytics.crashlytics().setCustomValue(budgetRemaining, forKey: "budget_remaining")
        
    }
}

// MARK: - Supporting Types

enum PurchaseSource: String {
    case iphone = "iphone"
    case appleWatch = "apple_watch"
    case widget = "widget"
    case watchWidget = "watch_widget"
}
