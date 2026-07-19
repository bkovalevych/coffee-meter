//
//  AddPurchaseView.swift
//  coffee meter
//
//  Created by Bohdan Kovalevych on 17.07.2026.
//

import SwiftUI
import SwiftData
import WidgetKit

struct AddPurchaseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var coffeeManager = CoffeeTypeManager.shared
    @State private var settings = UserSettings.shared

    // Quantities for each coffee type
    @State private var quantities: [PredefinedCoffeeType: Int] = [:]
    @State private var customQuantities: [UUID: Int] = [:]

    // Temporary state for editing prices
    @State private var editingPrices: [PredefinedCoffeeType: String] = [:]

    // State for adding new custom coffee
    @State private var showingAddCustom = false

    var totalAmount: Decimal {
        var total = Decimal(0)

        // Predefined coffees
        for type in PredefinedCoffeeType.allCases {
            let quantity = quantities[type] ?? 0
            total += coffeeManager.price(for: type) * Decimal(quantity)
        }

        // Custom coffees
        for custom in coffeeManager.customCoffees {
            let quantity = customQuantities[custom.id] ?? 0
            total += custom.price * Decimal(quantity)
        }

        return total
    }

    var hasAnySelection: Bool {
        let hasDefault = quantities.values.contains(where: { $0 > 0 })
        let hasCustom = customQuantities.values.contains(where: { $0 > 0 })
        return hasDefault || hasCustom
    }

    var body: some View {
        let _ = localization.currentLanguage // Force view to re-render
        let _ = settings.currentCurrency // Force view to re-render

        ZStack {
            Color.creamBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Title
                Text("add_purchase.title".localized())
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.coffeeBrown)
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Predefined coffees with editable prices
                        ForEach(PredefinedCoffeeType.allCases) { type in
                            coffeeRow(
                                name: type.displayName,
                                price: coffeeManager.price(for: type),
                                priceBinding: Binding(
                                    get: { editingPrices[type] ?? String(NSDecimalNumber(decimal: coffeeManager.price(for: type)).intValue) },
                                    set: { newValue in
                                        editingPrices[type] = newValue
                                        if let decimal = Decimal(string: newValue) {
                                            coffeeManager.updatePrice(for: type, to: decimal)
                                        }
                                    }
                                ),
                                quantity: Binding(
                                    get: { quantities[type] ?? 0 },
                                    set: { quantities[type] = $0 }
                                ),
                                isCustom: false,
                                onRemove: nil
                            )
                        }

                        // Custom coffees
                        ForEach(coffeeManager.customCoffees) { custom in
                            customCoffeeRow(
                                coffee: custom,
                                quantity: Binding(
                                    get: { customQuantities[custom.id] ?? 0 },
                                    set: { customQuantities[custom.id] = $0 }
                                ),
                                onRemove: {
                                    coffeeManager.removeCustomCoffee(id: custom.id)
                                }
                            )
                        }

                        // Add custom coffee button
                        if coffeeManager.canAddCustomCoffee {
                            Button {
                                showingAddCustom = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20))
                                    Text("add_purchase.add_custom".localized())
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundStyle(Color.accentOrange)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.accentOrange.opacity(0.3), lineWidth: 1.5)
                                )
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Total and submit button
                VStack(spacing: 16) {
                    Divider()
                        .background(Color.coffeeBrown.opacity(0.2))

                    HStack {
                        Text("add_purchase.total".localized())
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.coffeeBrown)

                        Spacer()

                        Text(totalAmount, format: .currency(code: settings.currency.rawValue))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.accentOrange)
                    }
                    .padding(.horizontal, 20)

                    Button {
                        addPurchases()
                    } label: {
                        HStack(spacing: 8) {
                            Text("add_purchase.submit_button".localized())
                            Text(totalAmount, format: .currency(code: settings.currency.rawValue))
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(hasAnySelection ? Color.accentOrange : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(!hasAnySelection)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showingAddCustom) {
            AddCustomCoffeeView()
        }
    }

    // MARK: - Coffee Row (for predefined coffees with editable price)

    @ViewBuilder
    private func coffeeRow(
        name: String,
        price: Decimal,
        priceBinding: Binding<String>,
        quantity: Binding<Int>,
        isCustom: Bool,
        onRemove: (() -> Void)?
    ) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.coffeeBrown)

                Spacer()

                if let onRemove = onRemove {
                    Button {
                        onRemove()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.red.opacity(0.7))
                    }
                }
            }
            .padding(.bottom, 8)

            HStack(spacing: 16) {
                // Price input (editable)
                HStack(spacing: 4) {
                    Text(settings.currency.symbol)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.coffeeBrown.opacity(0.7))

                    TextField("0", text: priceBinding)
                        .keyboardType(.numberPad)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.coffeeBrown)
                        .frame(minWidth: 40, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()

                // Quantity controls
                HStack(spacing: 12) {
                    Button {
                        if quantity.wrappedValue > 0 {
                            quantity.wrappedValue -= 1
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(quantity.wrappedValue > 0 ? Color.accentOrange : Color.gray)
                            .frame(width: 36, height: 36)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .disabled(quantity.wrappedValue == 0)

                    Text("\(quantity.wrappedValue)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.coffeeBrown)
                        .frame(minWidth: 24)

                    Button {
                        quantity.wrappedValue += 1
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.accentOrange)
                            .frame(width: 36, height: 36)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightCream)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Custom Coffee Row

    @ViewBuilder
    private func customCoffeeRow(
        coffee: CustomCoffee,
        quantity: Binding<Int>,
        onRemove: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 12) {
            // Name with label "свій напій"
            HStack {
                Text("add_purchase.custom_label".localized())
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.accentOrange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentOrange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Spacer()

                Button {
                    onRemove()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.red.opacity(0.7))
                }
            }

            Text(coffee.name.isEmpty ? "add_purchase.custom_coffee_placeholder".localized() : coffee.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.coffeeBrown)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                // Price display
                HStack(spacing: 4) {
                    Text(settings.currency.symbol)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.coffeeBrown.opacity(0.7))

                    Text("\(NSDecimalNumber(decimal: coffee.price).intValue)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.coffeeBrown)
                        .frame(minWidth: 40, alignment: .leading)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()

                // Quantity controls
                HStack(spacing: 12) {
                    Button {
                        if quantity.wrappedValue > 0 {
                            quantity.wrappedValue -= 1
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(quantity.wrappedValue > 0 ? Color.accentOrange : Color.gray)
                            .frame(width: 36, height: 36)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .disabled(quantity.wrappedValue == 0)

                    Text("\(quantity.wrappedValue)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.coffeeBrown)
                        .frame(minWidth: 24)

                    Button {
                        quantity.wrappedValue += 1
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.accentOrange)
                            .frame(width: 36, height: 36)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightCream)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Actions

    private func addPurchases() {
        withAnimation {
            var purchases: [(type: String, amount: Decimal, quantity: Int)] = []

            // Collect predefined coffee purchases
            for type in PredefinedCoffeeType.allCases {
                let quantity = quantities[type] ?? 0
                if quantity > 0 {
                    purchases.append((
                        type.displayName,
                        coffeeManager.price(for: type),
                        quantity
                    ))
                }
            }

            // Collect custom coffee purchases
            for custom in coffeeManager.customCoffees {
                let quantity = customQuantities[custom.id] ?? 0
                if quantity > 0 {
                    purchases.append((
                        custom.name.isEmpty ? "add_purchase.custom_coffee_placeholder".localized() : custom.name,
                        custom.price,
                        quantity
                    ))
                }
            }

            // Create purchase records
            for purchase in purchases {
                let coffeePurchase = CoffeePurchase(
                    amount: purchase.amount,
                    quantity: purchase.quantity,
                    coffeeName: purchase.type
                )
                modelContext.insert(coffeePurchase)

                // Track analytics
                AnalyticsManager.logCoffeeAdded(
                    amount: purchase.amount,
                    source: .iphone,
                    note: purchase.type
                )
            }

            // Save and dismiss
            try? modelContext.save()

            // Notify Watch about new purchase
            WatchConnectivityManager.shared.notifyPurchaseAdded()

            // Refresh iPhone widget immediately
            WidgetCenter.shared.reloadTimelines(ofKind: "CoffeeMeterWidget")

            dismiss()
        }
    }
}

// MARK: - Add Custom Coffee View

struct AddCustomCoffeeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var coffeeManager = CoffeeTypeManager.shared
    @StateObject private var localization = LocalizationManager.shared
    @State private var settings = UserSettings.shared

    @State private var customName = ""
    @State private var customPrice = ""

    var body: some View {
        let _ = localization.currentLanguage

        NavigationStack {
            ZStack {
                Color.creamBackground
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    // Name input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("add_purchase.custom_name_label".localized())
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.coffeeBrown.opacity(0.7))

                        TextField("add_purchase.custom_coffee_placeholder".localized(), text: $customName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.coffeeBrown)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Price input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("add_purchase.custom_price_label".localized())
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.coffeeBrown.opacity(0.7))

                        HStack(spacing: 4) {
                            Text(settings.currency.symbol)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color.coffeeBrown.opacity(0.7))

                            TextField("0", text: $customPrice)
                                .keyboardType(.numberPad)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(Color.coffeeBrown)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Spacer()

                    // Add button
                    Button {
                        if let price = Decimal(string: customPrice), !customName.isEmpty {
                            coffeeManager.addCustomCoffee(name: customName, price: price)
                            dismiss()
                        }
                    } label: {
                        Text("add_purchase.add_button".localized())
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                (!customName.isEmpty && Decimal(string: customPrice) != nil)
                                    ? Color.accentOrange
                                    : Color.gray
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(customName.isEmpty || Decimal(string: customPrice) == nil)
                }
                .padding(20)
            }
            .navigationTitle("add_purchase.add_custom".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("settings.close".localized()) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddPurchaseView()
        .modelContainer(for: CoffeePurchase.self, inMemory: true)
}
