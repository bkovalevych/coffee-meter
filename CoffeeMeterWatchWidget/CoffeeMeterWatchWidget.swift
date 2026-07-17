//
//  CoffeeMeterWatchWidget.swift
//  CoffeeMeterWatchWidget
//
//  Created by Bohdan Kovalevych on 17.07.2026.
//

import WidgetKit
import SwiftUI
import SwiftData

struct WatchProvider: TimelineProvider {
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
        return CoffeeCalculator.fetchMonthlyTotal(from: context)
    }
}

struct CoffeeEntry: TimelineEntry {
    let date: Date
    let monthlyTotal: Double
    let budget: Double
    let currency: Currency
}

// MARK: - Complication Views

struct WatchCircularView: View {
    var entry: WatchProvider.Entry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 1) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.orange)
                Text("\(Int(entry.monthlyTotal))")
                    .font(.system(size: 14, weight: .bold))
            }
        }
    }
}

struct WatchRectangularView: View {
    var entry: WatchProvider.Entry

    var progress: Double {
        CoffeeCalculator.budgetProgress(spent: entry.monthlyTotal, budget: entry.budget)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 14))
                Text("Coffee Meter")
                    .font(.system(size: 14, weight: .semibold))
            }

            Text("\(Int(entry.monthlyTotal))/\(Int(entry.budget)) \(entry.currency.symbol)")
                .font(.system(size: 18, weight: .bold))

            ProgressView(value: progress)
                .tint(.orange)
        }
    }
}

struct WatchInlineView: View {
    var entry: WatchProvider.Entry

    var body: some View {
        Text("☕ \(Int(entry.monthlyTotal))/\(Int(entry.budget)) \(entry.currency.symbol)")
    }
}

struct WatchCornerView: View {
    var entry: WatchProvider.Entry

    var progress: Double {
        CoffeeCalculator.budgetProgress(spent: entry.monthlyTotal, budget: entry.budget)
    }

    var body: some View {
        Text("\(Int(entry.monthlyTotal))")
            .font(.system(size: 20, weight: .bold))
            .widgetLabel {
                ProgressView(value: progress)
                    .tint(.orange)
            }
    }
}

// MARK: - Widget Configuration

struct CoffeeMeterWatchWidget: Widget {
    let kind: String = "CoffeeMeterWatchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WatchProvider()) { entry in
            CoffeeMeterWatchWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Coffee Meter")
        .description("Track your monthly coffee spending")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCorner
        ])
    }
}

struct CoffeeMeterWatchWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: WatchProvider.Entry

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            WatchCircularView(entry: entry)
        case .accessoryRectangular:
            WatchRectangularView(entry: entry)
        case .accessoryInline:
            WatchInlineView(entry: entry)
        case .accessoryCorner:
            WatchCornerView(entry: entry)
        default:
            WatchCircularView(entry: entry)
        }
    }
}

#Preview(as: .accessoryCircular) {
    CoffeeMeterWatchWidget()
} timeline: {
    CoffeeEntry(date: .now, monthlyTotal: 450, budget: 1000, currency: .uah)
    CoffeeEntry(date: .now, monthlyTotal: 750, budget: 1000, currency: .uah)
}

#Preview(as: .accessoryRectangular) {
    CoffeeMeterWatchWidget()
} timeline: {
    CoffeeEntry(date: .now, monthlyTotal: 450, budget: 1000, currency: .uah)
    CoffeeEntry(date: .now, monthlyTotal: 750, budget: 1000, currency: .uah)
}

#Preview(as: .accessoryInline) {
    CoffeeMeterWatchWidget()
} timeline: {
    CoffeeEntry(date: .now, monthlyTotal: 450, budget: 1000, currency: .uah)
}

#Preview(as: .accessoryCorner) {
    CoffeeMeterWatchWidget()
} timeline: {
    CoffeeEntry(date: .now, monthlyTotal: 450, budget: 1000, currency: .uah)
}
