//
//  DetailTradeViewModel.swift
//  eXchapp
//
//  Created by Cengizhan Özyurt on 22.08.2026.
//

import Foundation
import Combine

enum TradeType: String, CaseIterable {
    case buy = "Alış"
    case sell = "Satış"
}

@MainActor
final class TradeDetailViewModel: ObservableObject {
    
    @Published public var selectedCurrency: Currency
    @Published public var amountText: String = ""
    
    @Published public var userHoldings: [String: Double] =
    [
        "USD": 1250.0,
        "EUR": 450.0,
        "GBP": 120.0,
        "XAU": 4.5
    ]
    
    @Published public var alertMessage: String = ""
    @Published public var showAlert: Bool = false
    
    private let authManager = AuthManager.shared
    
    public init(initialCurrency: Currency) {
        self.selectedCurrency = initialCurrency
    }
    
    public var currentHolding: Double {
        userHoldings[selectedCurrency.id] ?? 0.0
    }
    
    public var inputAmount: Double {
        Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0.0
    }
    
    public var currentTLBalance: Double {
        authManager.currentUser?.balance ?? 0.0
    }
    
    public var estimatedTotalCost: Double {
        inputAmount * selectedCurrency.sellRate
    }
    
    public var estimatedTotalGain: Double {
        inputAmount * selectedCurrency.buyRate
    }
    
    public func selectCurrency(_ currency: Currency) {
        self.selectedCurrency = currency
        self.amountText = ""
    }
    
    public func executeBuy() {
        guard inputAmount > 0 else {
            triggerAlert("Lütfen geçerli bir miktar giriniz.")
            return
        }

        let totalCost = estimatedTotalCost
        guard currentTLBalance >= totalCost else {
            triggerAlert("Yetersiz TL bakiyesi! Gereken: \(String(format: "%.2f ₺", totalCost))")
            return
        }

        let newBalance = currentTLBalance - totalCost
        updateUserBalance(newBalance)

        userHoldings[selectedCurrency.id] = currentHolding + inputAmount

        triggerAlert("Tebrikler! \(String(format: "%.2f", inputAmount)) \(selectedCurrency.id) alış işleminiz gerçekleşti.")
        amountText = ""
    }
    
    public func executeSell() {
        guard inputAmount > 0 else {
            triggerAlert("Lütfen geçerli bir miktar giriniz.")
            return
        }
        
        guard currentHolding >= inputAmount else {
            triggerAlert("Yetersiz \(selectedCurrency.id) varlığı! Mevcut: \(String(format: "%.2f", currentHolding))")
            return
        }
        
        let totalGain = estimatedTotalGain
        let newBalance = currentTLBalance + totalGain
        updateUserBalance(newBalance)
        
        userHoldings[selectedCurrency.id] = currentHolding - inputAmount
        
        triggerAlert("Tebrikler! \(String(format: "%.2f", inputAmount)) \(selectedCurrency.id) satış işleminiz gerçekleşti.")
        amountText = ""
    }
    
    private func updateUserBalance(_ newBalance: Double) {
        guard let current = authManager.currentUser else { return }
        let updatedSession = UserSession(
            name: current.name,
            surname: current.surname,
            mail: current.mail,
            balance: newBalance
        )
        authManager.logIn(updatedSession)
    }
    
    private func triggerAlert(_ message: String) {
        self.alertMessage = message
        self.showAlert = true
    }
}
