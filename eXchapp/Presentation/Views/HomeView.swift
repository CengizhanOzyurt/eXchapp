//
//  HomeView.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 6.08.2026.
//

import SwiftUI

public struct HomeView: View {
    @AppStorage("liquidGlassEnabled") private var isLiquidGlassEnabled = false
    @StateObject private var viewModel = CurrencyViewModel()
    @StateObject private var authManager = AuthManager.shared
    
    @State private var showLoginAlert: Bool = false
    @State private var selectedTopTab: Int = 0
    @State private var selectedCurrencyForTrade: Currency? = nil
    
    public var onLoginPromptRequested: (() -> Void)?
    public var onRegisterPromptRequested: (() -> Void)?
    
    public init(onLoginPromptRequested: (() -> Void)? = nil, onRegisterPromptRequested: (() -> Void)? = nil) {
        self.onLoginPromptRequested = onLoginPromptRequested
        self.onRegisterPromptRequested = onRegisterPromptRequested
    }
    
    private let topTabs: [(icon: String, title: String)] = [
        ("tablecells", "Hesabım"),
        ("creditcard", "Kartlarım"),
        ("chart.pie", "Durumum")
    ]
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.background(isLiquid: isLiquidGlassEnabled)
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Button(action: {
                        if !authManager.isLoggedIn { showLoginAlert = true }
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(AppTheme.barForeground(isLiquid: isLiquidGlassEnabled))
                    }
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(isLiquidGlassEnabled ? .gray : AppTheme.isCepNavy.opacity(0.6))
                        Text("İşlem Ara")
                            .foregroundColor(isLiquidGlassEnabled ? .gray.opacity(0.8) : Color.gray)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(10)
                    .background(isLiquidGlassEnabled ? Color.white : Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(isLiquidGlassEnabled ? 0.0 : 0.05), radius: 4)
                    
                    Button(action: {
                        if !authManager.isLoggedIn { showLoginAlert = true }
                    }) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.barForeground(isLiquid: isLiquidGlassEnabled))
                            .padding(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                if authManager.isLoggedIn {
                    topTabBar
                        .padding(.top, 4)
                } else {
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(height: 3)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        if authManager.isLoggedIn {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Maaş Hesabım")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                                }
                                Text("**1480 7332 20**")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled).opacity(0.8))
                                
                                Text("Bakiyeniz")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                                    .padding(.top, 2)
                                
                                HStack {
                                    Text(String(format: "%.2f TL", authManager.currentUser?.balance ?? 0.0))
                                        .font(.system(size: 26, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                                }
                            }
                            .padding(18)
                            .appCard(isLiquid: isLiquidGlassEnabled, cornerRadius: 16)
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                            
                            HStack(spacing: 12) {
                                QuickActionButton(icon: "arrow.left.arrow.right", title: "Para Aktar", isLiquid: isLiquidGlassEnabled) { }
                                QuickActionButton(icon: "creditcard.fill", title: "Ödemeler", isLiquid: isLiquidGlassEnabled) { }
                                QuickActionButton(icon: "square.and.arrow.up", title: "IBAN Paylaş", isLiquid: isLiquidGlassEnabled) { }
                                QuickActionButton(icon: "ellipsis", title: "Daha Fazlası", isLiquid: isLiquidGlassEnabled) { }
                            }
                            .padding(.horizontal, 16)
                            
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(isLiquidGlassEnabled ? .white.opacity(0.9) : AppTheme.isCepNavy)
                                
                                Text("Hesap Bilgilerinizi Görüntüleyin")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                                
                                Text("Varlıklarınızı ve transfer işlemlerinizi görüntülemek için lütfen giriş yapınız.")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                                    .multilineTextAlignment(.center)
                                
                                Button {
                                    onLoginPromptRequested?()
                                } label: {
                                    Text("Giriş Yap veya Kaydol")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(isLiquidGlassEnabled ? .black : .white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(isLiquidGlassEnabled ? Color.white : AppTheme.isCepButton)
                                        .cornerRadius(12)
                                }
                                .padding(.top, 4)
                            }
                            .padding(20)
                            .appCard(isLiquid: isLiquidGlassEnabled)
                            .cornerRadius(14)
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Piyasa Kurları")
                                .font(.headline)
                                .foregroundColor(AppTheme.textWhite(isLiquid: isLiquidGlassEnabled))
                                .padding(.horizontal, 16)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(viewModel.currencies) { currency in
                                        Button {
                                            if !authManager.isLoggedIn {
                                                showLoginAlert = true
                                            } else {
                                                selectedCurrencyForTrade = currency
                                            }
                                        } label: {
                                            HStack(spacing: 12) {
                                                Text(currency.flagEmoji)
                                                    .font(.title2)
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(currency.id)
                                                        .font(.system(size: 16, weight: .bold))
                                                        .foregroundColor(AppTheme.textTertiary(isLiquid: isLiquidGlassEnabled))
                                                    Text(currency.name)
                                                        .font(.caption2)
                                                        .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                                                }
                                                
                                                Spacer()
                                                
                                                VStack(alignment: .trailing, spacing: 2) {
                                                    Text(String(format: "%.2f TL", currency.sellRate))
                                                        .font(.system(size: 15, weight: .semibold))
                                                        .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                                                    
                                                    HStack(spacing: 2) {
                                                        if currency.changePercent > 0 {
                                                            Image(systemName: "arrow.up.right")
                                                            Text(String(format: "+%.2f%%", currency.changePercent))
                                                        } else if currency.changePercent < 0 {
                                                            Image(systemName: "arrow.down.right")
                                                            Text(String(format: "%.2f%%", currency.changePercent))
                                                        } else {
                                                            Text("%0.00")
                                                        }
                                                    }
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(
                                                        currency.changePercent > 0 ? .green :
                                                        currency.changePercent < 0 ? .red :
                                                        AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled)
                                                    )
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .appCard(isLiquid: isLiquidGlassEnabled, cornerRadius: 14)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .sheet(item: $selectedCurrencyForTrade) { selected in
                                    TradeDetailView(currencyViewModel: viewModel, initialCurrency: selected)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 6)
                }
            }
        }
        .alert("Giriş Yapmanız Gerekiyor", isPresented: $showLoginAlert) {
            Button("Giriş Yap") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onLoginPromptRequested?()
                }
            }
            Button("Vazgeç", role: .cancel) { }
        } message: {
            Text("Lütfen işlemlerinizi gerçekleştirmek veya profilinizi görmek için giriş yapınız.")
        }
    }
    
    private var topTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Array(topTabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTopTab = index }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .medium))
                        Text(tab.title)
                            .font(.system(size: 13, weight: selectedTopTab == index ? .semibold : .regular))
                        Rectangle()
                            .fill(selectedTopTab == index ? (true ? Color.white : AppTheme.isCepNavy) : Color.clear)
                            .frame(height: 2)
                            .padding(.horizontal, 8)
                    }
                    .foregroundColor(selectedTopTab == index ? (true ? .white : AppTheme.isCepNavy) : .white.opacity(0.65))
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let isLiquid: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isLiquid ? .white : AppTheme.isCepNavy)
                    .frame(width: 44, height: 44)
                    .background(isLiquid ? Color.white.opacity(0.12) : Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(isLiquid ? 0.0 : 0.05), radius: 4)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview{
    HomeView()
}
