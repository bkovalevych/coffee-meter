//
//  CoffeePurchaseIntegrationTests.swift
//  coffee meterTests
//
//  Created by Bohdan Kovalevych on 17.07.2026.
//

import XCTest
import SwiftData
@testable import coffee_meter

final class CoffeePurchaseIntegrationTests: XCTestCase {

    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() {
        super.setUp()

        // Create in-memory container for testing
        do {
            let schema = Schema([CoffeePurchase.self])
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            container = try ModelContainer(for: schema, configurations: [configuration])
            context = ModelContext(container)
        } catch {
            XCTFail("Failed to set up test container: \(error)")
        }
    }

    override func tearDown() {
        container = nil
        context = nil
        super.tearDown()
    }

    // MARK: - Basic CRUD Tests

    func testInsertPurchase_SavesSuccessfully() throws {
        // Given
        let purchase = CoffeePurchase(amount: Decimal(50))

        // When
        context.insert(purchase)
        try context.save()

        // Then
        let descriptor = FetchDescriptor<CoffeePurchase>()
        let purchases = try context.fetch(descriptor)

        XCTAssertEqual(purchases.count, 1)
        XCTAssertEqual(purchases.first?.amount, Decimal(50))
    }

    // MARK: - Integration with CoffeeCalculator

    func testMonthlyTotal_WithStoredPurchases_CalculatesCorrectly() throws {
        // Given
        let purchase1 = CoffeePurchase(amount: Decimal(50))
        let purchase2 = CoffeePurchase(amount: Decimal(75))

        context.insert(purchase1)
        context.insert(purchase2)
        try context.save()

        // When
        let descriptor = FetchDescriptor<CoffeePurchase>()
        let purchases = try context.fetch(descriptor)
        let total = CoffeeCalculator.monthlyTotal(from: purchases)

        // Then
        XCTAssertEqual(total, Decimal(125))
    }

    func testMonthlyTotal_WithQuantities_CalculatesCorrectTotal() throws {
        // Given
        let purchase1 = CoffeePurchase(amount: Decimal(50), quantity: 2) // 100
        let purchase2 = CoffeePurchase(amount: Decimal(75), quantity: 1) // 75

        context.insert(purchase1)
        context.insert(purchase2)
        try context.save()

        // When
        let descriptor = FetchDescriptor<CoffeePurchase>()
        let purchases = try context.fetch(descriptor)
        let total = CoffeeCalculator.monthlyTotal(from: purchases)

        // Then
        XCTAssertEqual(total, Decimal(175))
    }

    // MARK: - Coffee Name Storage

    func testStoreCoffeeName_PersistsCorrectly() throws {
        // Given
        let purchase = CoffeePurchase(
            amount: Decimal(75),
            coffeeName: "Latte"
        )

        // When
        context.insert(purchase)
        try context.save()

        // Then
        let descriptor = FetchDescriptor<CoffeePurchase>()
        let purchases = try context.fetch(descriptor)

        XCTAssertEqual(purchases.first?.coffeeName, "Latte")
    }
}
