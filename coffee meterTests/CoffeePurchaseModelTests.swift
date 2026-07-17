//
//  CoffeePurchaseModelTests.swift
//  coffee meterTests
//
//  Created by Bohdan Kovalevych on 17.07.2026.
//

import XCTest
@testable import coffee_meter

final class CoffeePurchaseModelTests: XCTestCase {

    // MARK: - Initialization Tests

    func testInit_WithDefaultValues_CreatesValidPurchase() {
        // When
        let purchase = CoffeePurchase(amount: Decimal(50))

        // Then
        XCTAssertEqual(purchase.amount, Decimal(50))
        XCTAssertEqual(purchase.quantity, 1)
        XCTAssertNil(purchase.note)
        XCTAssertNil(purchase.coffeeName)
        XCTAssertNotNil(purchase.id)
        XCTAssertNotNil(purchase.date)
    }

    func testInit_WithAllParameters_CreatesValidPurchase() {
        // Given
        let amount = Decimal(75)
        let date = Date()
        let note = "Morning coffee"
        let quantity = 2
        let coffeeName = "Latte"

        // When
        let purchase = CoffeePurchase(
            amount: amount,
            date: date,
            note: note,
            quantity: quantity,
            coffeeName: coffeeName
        )

        // Then
        XCTAssertEqual(purchase.amount, amount)
        XCTAssertEqual(purchase.date, date)
        XCTAssertEqual(purchase.note, note)
        XCTAssertEqual(purchase.quantity, quantity)
        XCTAssertEqual(purchase.coffeeName, coffeeName)
    }

    func testInit_WithQuantity_StoresCorrectQuantity() {
        // When
        let purchase = CoffeePurchase(amount: Decimal(60), quantity: 3)

        // Then
        XCTAssertEqual(purchase.quantity, 3)
    }

    // MARK: - ID Tests

    func testInit_GeneratesUniqueIDs() {
        // When
        let purchase1 = CoffeePurchase(amount: Decimal(50))
        let purchase2 = CoffeePurchase(amount: Decimal(50))

        // Then
        XCTAssertNotEqual(purchase1.id, purchase2.id)
    }

    // MARK: - Edge Cases

    func testInit_WithZeroAmount_IsValid() {
        // When
        let purchase = CoffeePurchase(amount: Decimal(0))

        // Then
        XCTAssertEqual(purchase.amount, Decimal(0))
    }

    func testInit_WithLargeAmount_IsValid() {
        // When
        let purchase = CoffeePurchase(amount: Decimal(999999.99))

        // Then
        XCTAssertEqual(purchase.amount, Decimal(999999.99))
    }

    func testInit_WithZeroQuantity_StoresZero() {
        // When
        let purchase = CoffeePurchase(amount: Decimal(50), quantity: 0)

        // Then
        XCTAssertEqual(purchase.quantity, 0)
    }
}
