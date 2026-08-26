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
    @Published public var alertMessage: String = ""
    @Published public var showAlert: Bool = false
    
    private let authManager = AuthManager.shared
    
    public init(initialCurrency: Currency) {
        self.selectedCurrency = initialCurrency
    }
    
    public var userHoldings: [String: Double] {
        authManager.currentUser?.holdings ?? [:]
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
        var updatedHoldings = userHoldings
        updatedHoldings[selectedCurrency.id] = currentHolding + inputAmount
        
        updateUserData(newBalance: newBalance, newHoldings: updatedHoldings)

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
        
        var updatedHoldings = userHoldings
        updatedHoldings[selectedCurrency.id] = currentHolding - inputAmount
        
        updateUserData(newBalance: newBalance, newHoldings: updatedHoldings)
        
        triggerAlert("Tebrikler! \(String(format: "%.2f", inputAmount)) \(selectedCurrency.id) satış işleminiz gerçekleşti.")
        amountText = ""
    }
    
    private func updateUserData(newBalance: Double, newHoldings: [String: Double]) {
        guard let current = authManager.currentUser else { return }
        
        DatabaseManager.shared.updateUserBalance(mail: current.mail, newBalance: newBalance)
        
        for (currency, amount) in newHoldings {
            DatabaseManager.shared.updateUserHolding(mail: current.mail, currencyCode: currency, amount: amount)
        }
        
        let updatedSession = UserSession(
            name: current.name,
            surname: current.surname,
            mail: current.mail,
            balance: newBalance,
            holdings: newHoldings
        )
        authManager.logIn(updatedSession)
    }
    
    private func triggerAlert(_ message: String) {
        self.alertMessage = message
        self.showAlert = true
    }
}
