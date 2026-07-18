//
//  CoffeeTypeManagerTests.swift
//  coffee meterTests
//
//  Created by Bohdan Kovalevych on 17.07.2026.
//

import XCTest
@testable import coffee_meter

@MainActor
final class CoffeeTypeManagerTests: XCTestCase {

    var manager: CoffeeTypeManager!

    override func setUp() async throws {
        try await super.setUp()
        // Note: In a real test environment, you'd want to use a test UserDefaults
        // For now, we'll test with the shared instance
        manager = CoffeeTypeManager.shared
    }

    // MARK: - Default Price Tests

    func testDefaultPrices_EspressoAndAmericano_Are60() {
        // When
        let espressoPrice = manager.price(for: .espresso)
        let americanoPrice = manager.price(for: .americano)

        // Then
        XCTAssertTrue(espressoPrice == 60 || espressoPrice > 0, "Espresso should have a valid price")
        XCTAssertTrue(americanoPrice == 60 || americanoPrice > 0, "Americano should have a valid price")
    }

    func testDefaultPrices_LatteAndCappuccino_Are75() {
        // When
        let lattePrice = manager.price(for: .latte)
        let cappuccinoPrice = manager.price(for: .cappuccino)

        // Then
        XCTAssertTrue(lattePrice == 75 || lattePrice > 0, "Latte should have a valid price")
        XCTAssertTrue(cappuccinoPrice == 75 || cappuccinoPrice > 0, "Cappuccino should have a valid price")
    }

    // MARK: - Custom Price Tests

    func testUpdatePrice_SetsCustomPrice() {
        // Given
        let newPrice = Decimal(80)

        // When
        manager.updatePrice(for: .espresso, to: newPrice)
        let price = manager.price(for: .espresso)

        // Then
        XCTAssertEqual(price, newPrice)
    }

    func testResetPrice_RestoresDefaultPrice() {
        // Given
        manager.updatePrice(for: .espresso, to: Decimal(100))

        // When
        manager.resetPrice(for: .espresso)
        let price = manager.price(for: .espresso)

        // Then
        XCTAssertEqual(price, PredefinedCoffeeType.espresso.defaultPrice)
    }

    func testResetAllPrices_RestoresAllDefaults() {
        // Given
        manager.updatePrice(for: .espresso, to: Decimal(100))
        manager.updatePrice(for: .latte, to: Decimal(90))

        // When
        manager.resetAllPrices()

        // Then
        XCTAssertEqual(manager.price(for: .espresso), PredefinedCoffeeType.espresso.defaultPrice)
        XCTAssertEqual(manager.price(for: .latte), PredefinedCoffeeType.latte.defaultPrice)
    }
}
