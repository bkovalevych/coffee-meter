//
//  CoffeePurchase.swift
//  coffee meter
//
//  Created by Bohdan Kovalevych on 15.07.2026.
//

import Foundation
import SwiftData

@Model
final class CoffeePurchase {
    var id: UUID
    var amount: Decimal
    var date: Date
    var note: String?
    var quantity: Int = 1  // Default value for migration
    var coffeeName: String?  // Optional, so nil is the default

    init(amount: Decimal, date: Date = Date(), note: String? = nil, quantity: Int = 1, coffeeName: String? = nil) {
        self.id = UUID()
        self.amount = amount
        self.date = date
        self.note = note
        self.quantity = quantity
        self.coffeeName = coffeeName
    }
}
