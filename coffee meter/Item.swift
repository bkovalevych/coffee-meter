//
//  Item.swift
//  coffee meter
//
//  Created by Bohdan Kovalevych on 15.07.2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
