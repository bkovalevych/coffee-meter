//
//  CoffeeCalculator.swift
//  coffee meter
//
//  Created by Bohdan Kovalevych on 17.07.2026.
//

import Foundation
import SwiftData

/// Shared calculation logic for coffee spending across all targets
struct CoffeeCalculator {

    /// Calculate total spending for the current month from an array of purchases
    /// - Parameter purchases: Array of coffee purchases
    /// - Returns: Total spending as Decimal
    static func monthlyTotal(from purchases: [CoffeePurchase]) -> Decimal {
        let calendar = Calendar.current
        let now = Date()

        return purchases
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }

    /// Calculate total spending for the current month from SwiftData context
    /// - Parameter context: SwiftData ModelContext
    /// - Returns: Total spending as Double (for widgets)
    static func fetchMonthlyTotal(from context: ModelContext) -> Double {
        let calendar = Calendar.current
        let now = Date()

        let descriptor = FetchDescriptor<CoffeePurchase>(
            sortBy: [SortDescriptor(\CoffeePurchase.date, order: .reverse)]
        )

        do {
            let purchases = try context.fetch(descriptor)
            let monthlyPurchases = purchases.filter { purchase in
                calendar.isDate(purchase.date, equalTo: now, toGranularity: .month)
            }

            let total = monthlyPurchases.reduce(0.0) { sum, purchase in
                sum + NSDecimalNumber(decimal: purchase.amount).doubleValue
            }

            return total
        } catch {
            return 0.0
        }
    }

    /// Calculate remaining budget
    /// - Parameters:
    ///   - spent: Amount spent
    ///   - budget: Monthly budget
    /// - Returns: Remaining budget (minimum 0)
    static func budgetRemaining(spent: Decimal, budget: Double) -> Decimal {
        max(Decimal(budget) - spent, 0)
    }

    /// Calculate budget progress (0.0 to 1.0)
    /// - Parameters:
    ///   - spent: Amount spent (as Double)
    ///   - budget: Monthly budget
    /// - Returns: Progress ratio capped at 1.0
    static func budgetProgress(spent: Double, budget: Double) -> Double {
        min(spent / budget, 1.0)
    }
}
