//
//  SettingsView.swift
//  coffee meter
//
//  Created by Bohdan Kovalevych on 15.07.2026.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var purchases: [CoffeePurchase]

    @StateObject private var localization = LocalizationManager.shared
    @State private var settings = UserSettings.shared
    @State private var showComingSoon = false
    @State private var showResetConfirmation = false
    @State private var budgetText = ""

    var body: some View {
        let _ = localization.currentLanguage // Force view to re-render when language changes
        let _ = settings.currentCurrency // Force view to re-render when currency changes

        NavigationStack {
            ZStack {
                Color.creamBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Banks Section (Mocked)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("settings.banks.title".localized())
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.coffeeBrown)

                            bankRow(name: "settings.banks.monobank".localized(), color: .black, isEnabled: false)
                            bankRow(name: "settings.banks.privat".localized(), color: Color(red: 0.35, green: 0.63, blue: 0.31), isEnabled: false)
                        }
                        .padding(20)
                        .background(Color.lightCream)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Budget Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("settings.budget.title".localized())
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.coffeeBrown)

                            HStack(spacing: 12) {
                                TextField("1000", text: $budgetText)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.coffeeBrown)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .onChange(of: budgetText) { _, newValue in
                                        if let value = Double(newValue), value > 0 {
                                            settings.monthlyBudget = value
                                        }
                                    }

                                Text(settings.currency.symbol)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(Color.coffeeBrown)
                            }

                            Text("settings.budget.description".localized())
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(Color.coffeeBrown.opacity(0.7))
                        }
                        .padding(20)
                        .background(Color.lightCream)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Language Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("settings.language.title".localized())
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.coffeeBrown)

                            Menu {
                                ForEach(Language.allCases, id: \.self) { language in
                                    Button {
                                        if settings.language != language {
                                            settings.language = language
                                            localization.setLanguage(language)
                                        }
                                    } label: {
                                        HStack {
                                            Text(language.displayName)
                                            if settings.language == language {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(settings.language.displayName)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundStyle(Color.coffeeBrown)

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.coffeeBrown.opacity(0.5))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(20)
                        .background(Color.lightCream)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Currency Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("settings.currency.title".localized())
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.coffeeBrown)

                            Menu {
                                ForEach(Currency.allCases, id: \.self) { currency in
                                    Button {
                                        if settings.currency != currency {
                                            settings.currency = currency
                                        }
                                    } label: {
                                        HStack {
                                            Text(currency.displayName)
                                            if settings.currency == currency {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(settings.currency.displayName)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundStyle(Color.coffeeBrown)

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.coffeeBrown.opacity(0.5))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(20)
                        .background(Color.lightCream)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Reset Button
                        Button {
                            showResetConfirmation = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("settings.reset.button".localized())
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentOrange)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("settings.title".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("settings.done".localized()) {
                        dismiss()
                    }
                    .foregroundStyle(Color.coffeeBrown)
                    .fontWeight(.semibold)
                }
            }
            .alert("alert.coming_soon.title".localized(), isPresented: $showComingSoon) {
                Button("alert.coming_soon.ok".localized(), role: .cancel) { }
            } message: {
                Text("alert.coming_soon.bank_message".localized())
            }
            .alert("settings.reset.alert.title".localized(), isPresented: $showResetConfirmation) {
                Button("settings.reset.alert.cancel".localized(), role: .cancel) { }
                Button("settings.reset.alert.confirm".localized(), role: .destructive) {
                    resetToDefaults()
                }
            } message: {
                Text("settings.reset.alert.message".localized())
            }
            .onAppear {
                budgetText = String(format: "%.0f", settings.monthlyBudget)
            }
        }
    }

    private func bankRow(name: String, color: Color, isEnabled: Bool) -> some View {
        HStack(spacing: 16) {
            // Bank Icon
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 44, height: 44)

                Text(name.prefix(1).uppercased())
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.coffeeBrown)

                Text("settings.banks.description".localized())
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.coffeeBrown.opacity(0.6))
            }

            Spacer()

            Toggle("", isOn: .constant(false))
                .labelsHidden()
                .disabled(true)
                .tint(Color.accentOrange)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            showComingSoon = true
        }
    }

    private func resetToDefaults() {
        // Reset budget
        settings.resetToDefaults()
        budgetText = String(format: "%.0f", settings.monthlyBudget)

        // Delete all purchases
        purchases.forEach { purchase in
            modelContext.delete(purchase)
        }

        try? modelContext.save()
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: CoffeePurchase.self, inMemory: true)
}
