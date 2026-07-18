//
//  ContentView.swift
//  coffee meter
//
//  Created by Bohdan Kovalevych on 15.07.2026.
//

import SwiftUI
import SwiftData
import Charts

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CoffeePurchase.date, order: .reverse) private var purchases: [CoffeePurchase]

    @StateObject private var localization = LocalizationManager.shared
    @State private var settings = UserSettings.shared
    @State private var showSettings = false
    @State private var showChart = false
    @State private var showAddPurchase = false

    var body: some View {
        let _ = localization.currentLanguage // Force view to re-render when language changes
        let _ = settings.currentCurrency // Force view to re-render when currency changes

        ZStack {
            Color.creamBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Navigation
                HStack {
                    Button {
                        showSettings = true
                        AnalyticsManager.logSettingsOpened()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundStyle(Color.coffeeBrown)
                    }

                    Spacer()

                    Button {
                        showChart = true
                        AnalyticsManager.logChartOpened()
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
                            Text("app.title".localized())
                                .font(.system(size: 36, weight: .bold, design: .serif))
                                .foregroundStyle(Color.coffeeBrown)

                            Text("app.subtitle".localized())
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
                            showAddPurchase = true
                        } label: {
                            HStack(spacing: 8) {
                                Text("button.add_coffee".localized())
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
                            Text("card.monthly_spending".localized())
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.accentOrange)
                                .tracking(1)

                            Text(monthlyTotal, format: .currency(code: settings.currency.rawValue))
                                .font(.system(size: adaptivePriceFontSize, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.coffeeBrown)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)

                            Text("card.monthly_quote".localized())
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
                                Text("card.budget_remaining".localized())
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
                                Text("button.ai_excuse".localized())
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
        .onAppear {
            // Debug: Print App Group contents on iPhone
            print("📱 iPhone App Group Debug:")
            CoffeeTypeManager.shared.debugPrintAppGroupContents()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showChart) {
            ChartView()
        }
        .sheet(isPresented: $showAddPurchase) {
            AddPurchaseView()
        }
    }

    // MARK: - Computed Properties

    private var monthlyTotal: Decimal {
        CoffeeCalculator.monthlyTotal(from: purchases)
    }

    private var budgetRemaining: Decimal {
        CoffeeCalculator.budgetRemaining(spent: monthlyTotal, budget: settings.monthlyBudget)
    }

    private var budgetProgress: Double {
        let spent = NSDecimalNumber(decimal: monthlyTotal).doubleValue
        return CoffeeCalculator.budgetProgress(spent: spent, budget: settings.monthlyBudget)
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

}

// MARK: - Statistics View

struct ChartView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CoffeePurchase.date, order: .reverse) private var purchases: [CoffeePurchase]

    @StateObject private var localization = LocalizationManager.shared
    @State private var settings = UserSettings.shared

    var body: some View {
        let _ = localization.currentLanguage
        let _ = settings.currentCurrency

        NavigationStack {
            ZStack {
                Color.creamBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Monthly Total Summary
                        VStack(spacing: 8) {
                            Text("chart.total_this_month".localized())
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.accentOrange)
                                .tracking(1)

                            Text(monthlyTotal, format: .currency(code: settings.currency.rawValue))
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.coffeeBrown)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.lightCream)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        // Weekly Total Summary
                        VStack(spacing: 8) {
                            Text("chart.weekly_expenses".localized())
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.accentOrange)
                                .tracking(1)

                            Text(weeklyTotal, format: .currency(code: settings.currency.rawValue))
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.coffeeBrown)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.lightCream)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 20)

                        // Daily Expenses Chart
                        VStack(alignment: .leading, spacing: 16) {
                            Text("chart.daily_expenses".localized())
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.coffeeBrown)
                                .padding(.horizontal, 20)

                            if dailyData.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "chart.bar.xaxis")
                                        .font(.system(size: 48))
                                        .foregroundStyle(Color.coffeeBrown.opacity(0.3))

                                    Text("chart.no_data".localized())
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(Color.coffeeBrown.opacity(0.6))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                            } else {
                                Chart(dailyData) { item in
                                    BarMark(
                                        x: .value("chart.day".localized(), item.day),
                                        y: .value("chart.amount".localized(), item.total)
                                    )
                                    .foregroundStyle(Color.accentOrange.gradient)
                                    .cornerRadius(6)
                                }
                                .frame(height: 250)
                                .chartXAxis {
                                    AxisMarks(values: .automatic) { value in
                                        AxisValueLabel()
                                            .foregroundStyle(Color.coffeeBrown.opacity(0.7))
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks { value in
                                        AxisValueLabel()
                                            .foregroundStyle(Color.coffeeBrown.opacity(0.7))
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.lightCream)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 20)

                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationTitle("chart.title".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("settings.close".localized()) {
                        dismiss()
                    }
                    .foregroundStyle(Color.coffeeBrown)
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var monthlyTotal: Decimal {
        CoffeeCalculator.monthlyTotal(from: purchases)
    }

    private var weeklyTotal: Decimal {
        let calendar = Calendar.current
        let now = Date()

        // Get start of current week
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return 0
        }

        // Filter purchases for current week
        let weekPurchases = purchases.filter { purchase in
            guard let purchaseWeekStart = calendar.dateInterval(of: .weekOfYear, for: purchase.date)?.start else {
                return false
            }
            return calendar.isDate(purchaseWeekStart, equalTo: weekStart, toGranularity: .day)
        }

        // Calculate total
        return weekPurchases.reduce(Decimal.zero) { $0 + ($1.amount * Decimal($1.quantity)) }
    }

    private var dailyData: [DailyExpense] {
        let calendar = Calendar.current
        let now = Date()

        // Filter purchases for current month
        let monthPurchases = purchases.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }

        // Group by day
        let grouped = Dictionary(grouping: monthPurchases) { purchase -> Int in
            calendar.component(.day, from: purchase.date)
        }

        // Calculate daily totals
        let dailyTotals = grouped.map { day, purchases -> DailyExpense in
            let total = purchases.reduce(0.0) { sum, purchase in
                sum + (NSDecimalNumber(decimal: purchase.amount).doubleValue * Double(purchase.quantity))
            }
            return DailyExpense(day: day, total: total)
        }

        // Sort by day
        return dailyTotals.sorted { $0.day < $1.day }
    }
}

// MARK: - Data Models

struct DailyExpense: Identifiable {
    let id = UUID()
    let day: Int
    let total: Double
}

#Preview {
    ContentView()
        .modelContainer(for: CoffeePurchase.self, inMemory: true)
}
