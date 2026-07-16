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

    @State private var settings = UserSettings.shared
    @State private var showSettings = false
    @State private var showChart = false

    var body: some View {
        ZStack {
            Color.creamBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Navigation
                HStack {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundStyle(Color.coffeeBrown)
                    }

                    Spacer()

                    Button {
                        showChart = true
                    } label: {
                        Image(systemName: "chart.bar.fill")
                            .font(.title2)
                            .foregroundStyle(Color.coffeeBrown)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Title
                        VStack(spacing: 4) {
                            Text("Coffee Meter")
                                .font(.system(size: 36, weight: .bold, design: .serif))
                                .foregroundStyle(Color.coffeeBrown)

                            Text("офіційний бухгалтер твоєї кавової залежності")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color.coffeeBrown.opacity(0.7))
                                .italic()
                        }
                        .padding(.top, 8)

                        // Large Coffee Icon
                        ZStack {
                            Circle()
                                .fill(Color.coffeeBrown.opacity(0.1))
                                .frame(width: 180, height: 180)

                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(Color.coffeeBrown)
                        }
                        .padding(.vertical, 8)

                        // Add Coffee Button
                        Button {
                            addTestPurchase()
                        } label: {
                            HStack(spacing: 8) {
                                Text("Записати ще одну каву")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.accentOrange)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 20)

                        // Monthly Spending Card
                        VStack(spacing: 12) {
                            Text("ВИТРАЧЕНО ЦЬОГО МІСЯЦЯ")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.accentOrange)
                                .tracking(1)

                            Text(monthlyTotal, format: .currency(code: settings.currency.rawValue))
                                .font(.system(size: adaptivePriceFontSize, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.coffeeBrown)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)

                            Text("Ще трохи — і кав'ярня внесе тебе у заповіт.")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color.coffeeBrown.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .padding(.horizontal, 20)
                        .background(Color.lightCream)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 20)

                        // Budget Progress Bar
                        VStack(spacing: 16) {
                            HStack {
                                Text("ДО ГАНЬБИ ЛИШИЛОСЬ")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.accentOrange)
                                    .tracking(1)

                                Spacer()

                                Text(budgetRemaining, format: .currency(code: settings.currency.rawValue))
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.coffeeBrown)
                            }

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.darkCream)
                                        .frame(height: 12)

                                    // Progress
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.accentOrange)
                                        .frame(width: geometry.size.width * budgetProgress, height: 12)
                                }
                            }
                            .frame(height: 12)
                        }
                        .padding(.all, 20)
                        .background(Color.lightCream)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 20)

                        // AI Button
                        Button {
                            // TODO: AI functionality
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                Text("Придумати відмазку (AI)")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundStyle(Color.coffeeBrown)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.coffeeBrown.opacity(0.3), lineWidth: 1.5)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showChart) {
            ChartView()
        }
    }

    // MARK: - Computed Properties

    private var monthlyTotal: Decimal {
        let calendar = Calendar.current
        let now = Date()

        return purchases
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }

    private var budgetRemaining: Decimal {
        max(Decimal(settings.monthlyBudget) - monthlyTotal, 0)
    }

    private var budgetProgress: Double {
        let spent = NSDecimalNumber(decimal: monthlyTotal).doubleValue
        let budget = settings.monthlyBudget
        return min(spent / budget, 1.0)
    }

    private var adaptivePriceFontSize: CGFloat {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = settings.currency.rawValue
        let priceString = formatter.string(from: NSDecimalNumber(decimal: monthlyTotal)) ?? ""

        // Adjust font size based on string length
        let length = priceString.count
        if length > 15 {
            return 36
        } else if length > 12 {
            return 44
        } else if length > 10 {
            return 50
        } else {
            return 56
        }
    }

    // MARK: - Actions

    private func addTestPurchase() {
        withAnimation {
            let purchase = CoffeePurchase(amount: Decimal(string: "45.00")!, note: "Ранкове латте")
            modelContext.insert(purchase)
        }
    }
}

// MARK: - Placeholder Views

struct ChartView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("Chart - Coming Soon")
                .navigationTitle("Статистика")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Закрити") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: CoffeePurchase.self, inMemory: true)
}
