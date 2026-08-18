import Foundation
import Combine

@MainActor
final class CurrencyViewModel: ObservableObject {
    @Published var currencies: [Currency] = Currency.mock
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var previousRates: [String: Double] = [:]
    
    private var timer : Timer?

    init() {
        Task {
            await refresh()
        }
        startLiveSimulation()
    }
    private func startLiveSimulation() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.currencies = self.currencies.map { curr in
                    let randomDelta = Double.random(in: -0.45...0.45)
                    return Currency(
                        id: curr.id,
                        name: curr.name,
                        symbol: curr.symbol,
                        flagEmoji: curr.flagEmoji,
                        buyRate: curr.buyRate * (1 + randomDelta / 100),
                        sellRate: curr.sellRate * (1 + randomDelta / 100),
                        changePercent: randomDelta
                    )
                }
            }
        }
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await NetworkManager.shared.fetchLatestRates()
            let rawRates = response.rates ?? [:]
            
            currencies = Self.makeCurrencies(from: rawRates, previousRates: previousRates)
            
            previousRates = rawRates
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func rate(for id: String) -> Currency? {
        currencies.first { $0.id == id }
    }

    func convert(amount: Double, from fromID: String, to toID: String) -> Double {
        if fromID == toID { return amount }

        if fromID == "TRY" {
            guard let to = rate(for: toID) else { return 0 }
            return amount / to.sellRate
        }
        if toID == "TRY" {
            guard let from = rate(for: fromID) else { return 0 }
            return amount * from.buyRate
        }
        guard let from = rate(for: fromID), let to = rate(for: toID) else { return 0 }
        let tlAmount = amount * from.buyRate
        return tlAmount / to.sellRate
    }

    private static func makeCurrencies(from rates: [String: Double], previousRates: [String: Double]) -> [Currency] {
        let definitions: [(id: String, name: String, symbol: String, flagEmoji: String)] = [
            ("USD", "Amerikan Doları", "$", "🇺🇸"),
            ("EUR", "Euro", "€", "🇪🇺"),
            ("GBP", "İngiliz Sterlini", "£", "🇬🇧"),
            ("CHF", "İsviçre Frangı", "CHF", "🇨🇭"),
            ("JPY", "Japon Yeni", "¥", "🇯🇵"),
            ("AUD", "Avustralya Doları", "A$", "🇦🇺"),
            ("SEK", "İsveç Kronu", "SEK", "🇸🇪"),
            ("NOK", "Norveç Kronu", "NOK", "🇳🇴"),
            ("SAR", "Suudi Riyali", "SAR", "🇸🇦"),
            ("XAU", "Gram Altın", "XAU", "🟡"),
            ("XAG", "Gram Gümüş", "XAG", "⚪️")
        ]

        let troyOunceToGram = 31.1035

        return definitions.compactMap { definition in
            guard let apiRate = rates[definition.id.lowercased()], apiRate > 0 else {
                return nil
            }

            var currentTryRate = 1.0 / apiRate
            if definition.id == "XAU" || definition.id == "XAG" {
                currentTryRate /= troyOunceToGram
            }
            
            var changePercentage: Double = 0.0
            if let prevApiRate = previousRates[definition.id.lowercased()], prevApiRate > 0 {
                var prevTryRate = 1.0 / prevApiRate
                if definition.id == "XAU" || definition.id == "XAG" {
                    prevTryRate /= troyOunceToGram
                }
                
                changePercentage = ((currentTryRate - prevTryRate) / prevTryRate) * 100.0
            }
            
            return Currency(
                id: definition.id,
                name: definition.name,
                symbol: definition.symbol,
                flagEmoji: definition.flagEmoji,
                buyRate: currentTryRate * 0.997,
                sellRate: currentTryRate * 1.003,
                changePercent: changePercentage
            )
        }
    }
}
