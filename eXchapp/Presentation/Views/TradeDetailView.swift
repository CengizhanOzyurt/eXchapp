//
//  TradeDetailView.swift
//  eXchapp
//
//  Created by Cengizhan Özyurt on 21.08.2026.
//
/*
import SwiftUI

public struct TradeDetailView: View {
    @AppStorage("liquidGlassEnabled") private var isLiquidGlassEnabled = false
    @ObservedObject var viewModel: CurrencyViewModel
    @StateObject private var authManager = AuthManager.shared
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCurrency: Currency
    @State private var amountText: String = ""
    @State private var userHoldings: [String: Double] = ["USD": 1250.0, "EUR": 450.0, "GBP": 120.0, "XAU": 4.5]
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    public init(viewModel: CurrencyViewModel, initialCurrency: Currency) {
        self.viewModel = viewModel
        self._selectedCurrency = State(initialValue: initialCurrency)
    }
    
    private var currentRateCurrency: Currency {
        viewModel.currencies.first(where: $0.id == selectedCurrency.id }) ?? selectedCurrency
    }
private var currentHolding: Double {
    userHoldings[currentRateCurrency.id] ?? 0.0
}
    
    
    
    
    public var body: some View {
        
    }
    
}
*/
