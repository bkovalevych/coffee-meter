//
//  AddCoffeeView.swift
//  CoffeeMeterWatch Watch App
//
//  Created by Bohdan Kovalevych on 17.07.2026.
//

import SwiftUI
import SwiftData

struct AddCoffeeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @StateObject private var coffeeManager = CoffeeTypeManager.shared
    @State private var settings = UserSettings.shared

    // Quantities for predefined coffees (by type)
    @State private var predefinedQuantities: [PredefinedCoffeeType: Int] = [:]
    // Quantities for custom coffees (by id)
    @State private var customQuantities: [UUID: Int] = [:]

    var totalAmount: Decimal {
        var total = Decimal(0)

        // Predefined coffees
        for (type, quantity) in predefinedQuantities where quantity > 0 {
            let price = coffeeManager.price(for: type)
            total += price * Decimal(quantity)
        }

        // Custom coffees
        for coffee in coffeeManager.customCoffees {
            let quantity = customQuantities[coffee.id] ?? 0
            if quantity > 0 {
                total += coffee.price * Decimal(quantity)
            }
        }

        return total
    }

    var hasAnySelection: Bool {
        let hasPredef = predefinedQuantities.values.contains(where: { $0 > 0 })
        let hasCustom = customQuantities.values.contains(where: { $0 > 0 })
        return hasPredef || hasCustom
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    // Predefined coffees
                    Section {
                        ForEach(PredefinedCoffeeType.allCases) { type in
                            coffeeRow(
                                name: type.displayName,
                                price: coffeeManager.price(for: type),
                                quantity: Binding(
                                    get: { predefinedQuantities[type] ?? 0 },
                                    set: { predefinedQuantities[type] = $0 }
                                )
                            )
                        }
                    }

                    // Custom coffees
                    if !coffeeManager.customCoffees.isEmpty {
                        Section {
                            ForEach(coffeeManager.customCoffees) { coffee in
                                coffeeRow(
                                    name: coffee.name,
                                    price: coffee.price,
                                    quantity: Binding(
                                        get: { customQuantities[coffee.id] ?? 0 },
                                        set: { customQuantities[coffee.id] = $0 }
                                    )
                                )
                            }
                        }
                    }
                }
                .listStyle(.plain)

                // Submit button - pinned to bottom
                Button {
                    addPurchases()
                } label: {
                    HStack {
                        Text("Add")
                        Spacer()
                        Text(totalAmount, format: .currency(code: settings.currency.rawValue))
                    }
                    .font(.headline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(!hasAnySelection)
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
            }
            .navigationTitle("Add Coffee")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Debug: Print what's in App Group
                coffeeManager.debugPrintAppGroupContents()

                // Refresh data when view appears to ensure we have latest from iPhone
                coffeeManager.refresh()

                // Request fresh coffee data from iPhone (for simulator compatibility)
                WatchConnectivityManager.shared.requestCoffeeDataFromPhone()
            }
        }
    }

    // MARK: - Coffee Row

    @ViewBuilder
    private func coffeeRow(
        name: String,
        price: Decimal,
        quantity: Binding<Int>
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.headline)

            HStack {
                Text(price, format: .currency(code: settings.currency.rawValue))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                // Quantity controls
                HStack(spacing: 8) {
                    Button {
                        if quantity.wrappedValue > 0 {
                            quantity.wrappedValue -= 1
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(quantity.wrappedValue > 0 ? .orange : .gray)
                    }
                    .buttonStyle(.plain)
                    .disabled(quantity.wrappedValue == 0)

                    Text("\(quantity.wrappedValue)")
                        .font(.headline)
                        .frame(minWidth: 20)

                    Button {
                        quantity.wrappedValue += 1
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.orange)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Actions

    private func addPurchases() {
        withAnimation {
            var purchases: [(name: String, amount: Decimal, quantity: Int)] = []

            // Collect predefined coffee purchases
            for (type, quantity) in predefinedQuantities where quantity > 0 {
                purchases.append((
                    type.displayName,
                    coffeeManager.price(for: type),
                    quantity
                ))
            }

            // Collect custom coffee purchases
            for coffee in coffeeManager.customCoffees {
                let quantity = customQuantities[coffee.id] ?? 0
                if quantity > 0 {
                    purchases.append((
                        coffee.name,
                        coffee.price,
                        quantity
                    ))
                }
            }

            // Create purchase records
            for purchase in purchases {
                let coffeePurchase = CoffeePurchase(
                    amount: purchase.amount,
                    quantity: purchase.quantity,
                    coffeeName: purchase.name
                )
                modelContext.insert(coffeePurchase)
            }

            // Save and dismiss
            try? modelContext.save()
            dismiss()
        }
    }
}

#Preview {
    AddCoffeeView()
        .modelContainer(for: CoffeePurchase.self, inMemory: true)
}
