//
//  CoffeeCalculatorTests.swift
//  coffee meterTests
//
//  Created by Bohdan Kovalevych on 17.07.2026.
//

import XCTest
@testable import coffee_meter

final class CoffeeCalculatorTests: XCTestCase {

    // MARK: - Monthly Total Tests

    func testMonthlyTotal_WithNoPurchases_ReturnsZero() {
        // Given
        let purchases: [CoffeePurchase] = []

        // When
        let total = CoffeeCalculator.monthlyTotal(from: purchases)

        // Then
        XCTAssertEqual(total, 0)
    }

    func testMonthlyTotal_WithCurrentMonthPurchases_ReturnsCorrectSum() {
        // Given
        let purchases = [
            CoffeePurchase(amount: Decimal(50)),
            CoffeePurchase(amount: Decimal(75)),
            CoffeePurchase(amount: Decimal(100))
        ]

        // When
        let total = CoffeeCalculator.monthlyTotal(from: purchases)

        // Then
        XCTAssertEqual(total, Decimal(225))
    }

    func testMonthlyTotal_WithOldPurchases_IgnoresOldOnes() {
        // Given
        let calendar = Calendar.current
        let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: Date())!

        let purchases = [
            CoffeePurchase(amount: Decimal(50), date: Date()), // Current
            CoffeePurchase(amount: Decimal(75), date: twoMonthsAgo) // Old
        ]

        // When
        let total = CoffeeCalculator.monthlyTotal(from: purchases)

        // Then
        XCTAssertEqual(total, Decimal(50))
    }

    func testMonthlyTotal_WithQuantity_CalculatesCorrectly() {
        // Given
        let purchases = [
            CoffeePurchase(amount: Decimal(50), quantity: 2), // 100 total
            CoffeePurchase(amount: Decimal(75), quantity: 1)  // 75 total
        ]

        // When
        let total = CoffeeCalculator.monthlyTotal(from: purchases)

        // Then
        XCTAssertEqual(total, Decimal(175))
    }

    // MARK: - Budget Remaining Tests

    func testBudgetRemaining_WithNoSpending_ReturnsFullBudget() {
        // Given
        let spent = Decimal(0)
        let budget = 1000.0

        // When
        let remaining = CoffeeCalculator.budgetRemaining(spent: spent, budget: budget)

        // Then
        XCTAssertEqual(remaining, Decimal(1000))
    }

    func testBudgetRemaining_WithPartialSpending_ReturnsCorrectAmount() {
        // Given
        let spent = Decimal(300)
        let budget = 1000.0

        // When
        let remaining = CoffeeCalculator.budgetRemaining(spent: spent, budget: budget)

        // Then
        XCTAssertEqual(remaining, Decimal(700))
    }

    func testBudgetRemaining_WhenBudgetExceeded_ReturnsZero() {
        // Given
        let spent = Decimal(1200)
        let budget = 1000.0

        // When
        let remaining = CoffeeCalculator.budgetRemaining(spent: spent, budget: budget)

        // Then
        XCTAssertEqual(remaining, 0)
    }

    // MARK: - Budget Progress Tests

    func testBudgetProgress_WithNoSpending_ReturnsZero() {
        // Given
        let spent = 0.0
        let budget = 1000.0

        // When
        let progress = CoffeeCalculator.budgetProgress(spent: spent, budget: budget)

        // Then
        XCTAssertEqual(progress, 0.0, accuracy: 0.001)
    }

    func testBudgetProgress_WithHalfBudgetSpent_ReturnsHalf() {
        // Given
        let spent = 500.0
        let budget = 1000.0

        // When
        let progress = CoffeeCalculator.budgetProgress(spent: spent, budget: budget)

        // Then
        XCTAssertEqual(progress, 0.5, accuracy: 0.001)
    }

    func testBudgetProgress_WhenBudgetExceeded_ReturnsOne() {
        // Given
        let spent = 1500.0
        let budget = 1000.0

        // When
        let progress = CoffeeCalculator.budgetProgress(spent: spent, budget: budget)

        // Then
        XCTAssertEqual(progress, 1.0, accuracy: 0.001)
    }

    func testBudgetProgress_WithZeroBudget_ReturnsOne() {
        // Given
        let spent = 100.0
        let budget = 0.0

        // When
        let progress = CoffeeCalculator.budgetProgress(spent: spent, budget: budget)

        // Then
        XCTAssertEqual(progress, 1.0, accuracy: 0.001)
    }
}
