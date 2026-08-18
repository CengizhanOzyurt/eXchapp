//
//  ExchangeViewModel.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 6.08.2026.
//
/*/
import Foundation
import Combine

// MARK: - Exchange View Model
/// Manages the state, business logic, and data flow for exchange rate screens.
/// - Author: Cengizhan Özyurt
/// - Version: 1.0.0
public final class ExchangeViewModel: ObservableObject {
    
    // MARK: - Published Properties (UI State)
    @Published public var rates: [String: Double] = [: ]
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var lastUpdatedDate: String = ""
    
    public init(){
        Task {
            await fetchRates()
        }
    }
    
    // MARK: - Business Logic & Data Fetching
    @MainActor
    public func fetchRates() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await NetworkManager.shared.fetchLatestRates()
            
            let convertedRates = response.rates?.mapValues {rate in return rate > 0 ? (1.0 / rate) : 0.0
            } ?? [:]
            
            let troyOunceToGram = 31.1035
            let popularCurrencies = ["usd", "eur", "gbp", "xau", "xag","chf", "jpy", "aud", "sek", "nok", "sar"]
            
            var filteredRates = convertedRates.filter { currency, _ in return popularCurrencies.contains(currency.lowercased())
            }
            
            if let goldRate = filteredRates["xau"] {
                filteredRates["xau"] = goldRate / troyOunceToGram
            }
            
            if let silverRate = filteredRates["xag"] {
                filteredRates["xag"] = silverRate / troyOunceToGram
            }
            
            
            self.rates = filteredRates
            self.lastUpdatedDate = response.date
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}
*/
