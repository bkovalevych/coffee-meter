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

    @State private var settings = UserSettings.shared
    @State private var showComingSoon = false
    @State private var showResetConfirmation = false
    @State private var budgetText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.creamBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Banks Section (Mocked)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Підключені банки")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.coffeeBrown)

                            bankRow(name: "monobank", color: .black, isEnabled: false)
                            bankRow(name: "Приват24", color: Color(red: 0.35, green: 0.63, blue: 0.31), isEnabled: false)
                        }
                        .padding(20)
                        .background(Color.lightCream)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Budget Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Місячний бюджет")
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

                            Text("Максимальна сума витрат на каву за місяць")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(Color.coffeeBrown.opacity(0.7))
                        }
                        .padding(20)
                        .background(Color.lightCream)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Language Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Мова")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.coffeeBrown)

                            Picker("Мова", selection: $settings.language) {
                                ForEach(Language.allCases, id: \.self) { language in
                                    Text(language.displayName).tag(language)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(20)
                        .background(Color.lightCream)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Currency Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Валюта")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.coffeeBrown)

                            Picker("Валюта", selection: $settings.currency) {
                                ForEach(Currency.allCases, id: \.self) { currency in
                                    Text(currency.displayName).tag(currency)
                                }
                            }
                            .pickerStyle(.segmented)
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
                                Text("Скинути до заводських налаштувань")
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
            .navigationTitle("Налаштування")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundStyle(Color.coffeeBrown)
                    .fontWeight(.semibold)
                }
            }
            .alert("Незабаром!", isPresented: $showComingSoon) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Підключення банків буде доступне в наступній версії")
            }
            .alert("Скинути налаштування?", isPresented: $showResetConfirmation) {
                Button("Скасувати", role: .cancel) { }
                Button("Скинути", role: .destructive) {
                    resetToDefaults()
                }
            } message: {
                Text("Це видалить всі записи про покупки кави та скине бюджет до значення за замовчуванням (1000). Мова та валюта залишаться незмінними.")
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

                Text("Автозапис оплат кав'ярень")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.coffeeBrown.opacity(0.6))
            }

            Spacer()

            Toggle("", isOn: .constant(false))
                .labelsHidden()
                .onChange(of: isEnabled) { _, _ in
                    showComingSoon = true
                }
                .disabled(true)
                .tint(Color.accentOrange)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
