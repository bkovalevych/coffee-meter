//
//  coffee_meterTests.swift
//  coffee meterTests
//
//  Created by Bohdan Kovalevych on 15.07.2026.
//

import XCTest
@testable import coffee_meter

final class coffee_meterTests: XCTestCase {

    // MARK: - Sanity Tests

    func testDecimalArithmetic_WorksCorrectly() {
        // Given
        let a = Decimal(50.5)
        let b = Decimal(25.25)

        // When
        let sum = a + b

        // Then
        XCTAssertEqual(sum, Decimal(75.75))
    }

    func testCurrency_HasCorrectSymbols() {
        // Then
        XCTAssertEqual(Currency.uah.symbol, "₴")
        XCTAssertEqual(Currency.usd.symbol, "$")
    }

    func testLanguage_HasAllCases() {
        // Then
        XCTAssertEqual(Language.allCases.count, 2)
        XCTAssertTrue(Language.allCases.contains(.ukrainian))
        XCTAssertTrue(Language.allCases.contains(.english))
    }

    func testPredefinedCoffeeTypes_HaveCorrectCount() {
        // Then
        XCTAssertEqual(PredefinedCoffeeType.allCases.count, 4)
    }

    func testPredefinedCoffeeTypes_HaveDefaultPrices() {
        // Then
        XCTAssertEqual(PredefinedCoffeeType.espresso.defaultPrice, 60)
        XCTAssertEqual(PredefinedCoffeeType.americano.defaultPrice, 60)
        XCTAssertEqual(PredefinedCoffeeType.latte.defaultPrice, 75)
        XCTAssertEqual(PredefinedCoffeeType.cappuccino.defaultPrice, 75)
    }
}
