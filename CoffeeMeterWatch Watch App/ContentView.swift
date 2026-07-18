//
//  ContentView.swift
//  CoffeeMeterWatch Watch App
//
//  Created by Bohdan Kovalevych on 17.07.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CoffeePurchase.date, order: .reverse) private var purchases: [CoffeePurchase]

    @State private var settings = UserSettings.shared
    @State private var showingAddCoffee = false

    var monthlyTotal: Double {
        let decimal = CoffeeCalculator.monthlyTotal(from: purchases)
        return NSDecimalNumber(decimal: decimal).doubleValue
    }

    var budgetRemaining: Double {
        max(settings.monthlyBudget - monthlyTotal, 0)
    }

    var budgetProgress: Double {
        CoffeeCalculator.budgetProgress(spent: monthlyTotal, budget: settings.monthlyBudget)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Coffee icon
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.orange)

            // Monthly total
            VStack(spacing: 4) {
                Text("This Month")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(monthlyTotal, format: .currency(code: settings.currency.rawValue))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
            }

            // Progress bar
            VStack(spacing: 4) {
                ProgressView(value: budgetProgress)
                    .tint(.orange)

                Text("\(Int(budgetRemaining)) \(settings.currency.symbol) left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Add coffee button
            Button {
                showingAddCoffee = true
            } label: {
                Label("Add Coffee", systemImage: "plus")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .padding()
        .sheet(isPresented: $showingAddCoffee) {
            AddCoffeeView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: CoffeePurchase.self, inMemory: true)
}
