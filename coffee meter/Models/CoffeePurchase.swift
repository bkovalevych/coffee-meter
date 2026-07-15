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

    init(amount: Decimal, date: Date = Date(), note: String? = nil) {
        self.id = UUID()
        self.amount = amount
        self.date = date
        self.note = note
    }
}
