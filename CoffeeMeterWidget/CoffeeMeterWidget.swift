//
//  CoffeeMeterWidget.swift
//  CoffeeMeterWidget
//
//  Created by Bohdan Kovalevych on 17.07.2026.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([CoffeePurchase.self])
            let appGroupID = "group.useless.com.coffee-meter"
            let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!
            let modelConfiguration = ModelConfiguration(url: containerURL.appendingPathComponent("CoffeeMeter.sqlite"))
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    func placeholder(in context: Context) -> CoffeeEntry {
        CoffeeEntry(date: Date(), monthlyTotal: 450.00, budget: 1000.00, currency: .uah)
    }

    func getSnapshot(in context: Context, completion: @escaping (CoffeeEntry) -> ()) {
        let entry = CoffeeEntry(date: Date(), monthlyTotal: 450.00, budget: 1000.00, currency: .uah)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let settings = UserSettings.shared

        // Fetch monthly total from SwiftData
        let monthlyTotal = fetchMonthlyTotal()

        let entry = CoffeeEntry(
            date: currentDate,
            monthlyTotal: monthlyTotal,
            budget: settings.monthlyBudget,
            currency: settings.currency
        )

        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func fetchMonthlyTotal() -> Double {
        let context = ModelContext(modelContainer)
        let calendar = Calendar.current
        let now = Date()

        let descriptor = FetchDescriptor<CoffeePurchase>(
            sortBy: [SortDescriptor(\CoffeePurchase.date, order: .reverse)]
        )

        do {
            let purchases = try context.fetch(descriptor)
            let monthlyPurchases = purchases.filter { purchase in
                calendar.isDate(purchase.date, equalTo: now, toGranularity: .month)
            }

            let total = monthlyPurchases.reduce(0.0) { sum, purchase in
                sum + NSDecimalNumber(decimal: purchase.amount).doubleValue
            }

            return total
        } catch {
            return 0.0
        }
    }
}

struct CoffeeEntry: TimelineEntry {
    let date: Date
    let monthlyTotal: Double
    let budget: Double
    let currency: Currency
}

// MARK: - Widget Views

struct CoffeeMeterCircularView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 2) {
                Text(entry.currency.symbol)
                    .font(.system(size: 14, weight: .semibold))
                Text("\(Int(entry.monthlyTotal))")
                    .font(.system(size: 16, weight: .bold))
            }
        }
    }
}

struct CoffeeMeterRectangularView: View {
    var entry: Provider.Entry

    var progress: Double {
        min(entry.monthlyTotal / entry.budget, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 14))
                Text("Coffee")
                    .font(.system(size: 14, weight: .semibold))
            }

            Text("\(Int(entry.monthlyTotal))/\(Int(entry.budget)) \(entry.currency.symbol)")
                .font(.system(size: 18, weight: .bold))

            ProgressView(value: progress)
                .tint(.orange)
        }
    }
}

struct CoffeeMeterInlineView: View {
    var entry: Provider.Entry

    var body: some View {
        Text("☕ \(Int(entry.monthlyTotal))/\(Int(entry.budget)) \(entry.currency.symbol)")
    }
}

// MARK: - Widget Configuration

struct CoffeeMeterWidget: Widget {
    let kind: String = "CoffeeMeterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CoffeeMeterWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                CoffeeMeterWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Coffee Meter")
        .description("Track your monthly coffee spending")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct CoffeeMeterWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            CoffeeMeterCircularView(entry: entry)
        case .accessoryRectangular:
            CoffeeMeterRectangularView(entry: entry)
        case .accessoryInline:
            CoffeeMeterInlineView(entry: entry)
        default:
            CoffeeMeterRectangularView(entry: entry)
        }
    }
}

#Preview(as: .accessoryCircular) {
    CoffeeMeterWidget()
} timeline: {
    CoffeeEntry(date: .now, monthlyTotal: 450, budget: 1000, currency: .uah)
    CoffeeEntry(date: .now, monthlyTotal: 750, budget: 1000, currency: .uah)
}

#Preview(as: .accessoryRectangular) {
    CoffeeMeterWidget()
} timeline: {
    CoffeeEntry(date: .now, monthlyTotal: 450, budget: 1000, currency: .uah)
    CoffeeEntry(date: .now, monthlyTotal: 750, budget: 1000, currency: .uah)
}

#Preview(as: .accessoryInline) {
    CoffeeMeterWidget()
} timeline: {
    CoffeeEntry(date: .now, monthlyTotal: 450, budget: 1000, currency: .uah)
}
