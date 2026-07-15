//
//  ContentView.swift
//  coffee meter
//
//  Created by Bohdan Kovalevych on 15.07.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CoffeePurchase.date, order: .reverse) private var purchases: [CoffeePurchase]

    var body: some View {
        NavigationStack {
            VStack {
                monthlyTotalCard

                purchasesList
            }
            .navigationTitle("☕️ Coffee Meter")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // TODO: Show add purchase sheet
                        addTestPurchase()
                    } label: {
                        Label("Add Coffee", systemImage: "plus.circle.fill")
                    }
                }
            }
        }
    }

    private var monthlyTotalCard: some View {
        VStack(spacing: 8) {
            Text("This Month")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(monthlyTotal, format: .currency(code: "USD"))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var purchasesList: some View {
        List {
            ForEach(purchases) { purchase in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(purchase.date, style: .date)
                            .font(.subheadline)
                        if let note = purchase.note {
                            Text(note)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    Text(purchase.amount as NSDecimalNumber, formatter: currencyFormatter)
                        .font(.headline)
                }
            }
            .onDelete(perform: deletePurchases)
        }
        .listStyle(.insetGrouped)
    }

    private var monthlyTotal: Decimal {
        let calendar = Calendar.current
        let now = Date()

        return purchases
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }

    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }

    private func addTestPurchase() {
        withAnimation {
            let purchase = CoffeePurchase(amount: Decimal(string: "4.50")!, note: "Morning latte")
            modelContext.insert(purchase)
        }
    }

    private func deletePurchases(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(purchases[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: CoffeePurchase.self, inMemory: true)
}
