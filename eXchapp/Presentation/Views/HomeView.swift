//
//  HomeView.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 6.08.2026.
//

import SwiftUI

// MARK: - Home View
public struct HomeView: View {
    
    @StateObject private var viewModel = CurrencyViewModel()
    @State private var showLoginAlert: Bool = false
    @State private var navigateToConvert: Bool = false
    @State private var selectedTopTab: Int = 0
    
    public var onLoginPromptRequested: (() -> Void)?
    public var onRegisterPromptRequested: (() -> Void)?
    
    public init (onLoginPromptRequested: (() -> Void)? = nil, onRegisterPromptRequested: (() -> Void)? = nil) {
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
            
            LinearGradient(
                colors: [Color(hex: "0B4DB7"), Color(hex: "082870"), Color(hex: "04123A")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                HStack(spacing: 12) {
                    Button(action: { showLoginAlert = true }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.white)
                    }
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text("İşlem Ara")
                            .foregroundColor(.gray.opacity(0.8))
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(20)
                    
                    Button(action: { showLoginAlert = true }) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                topTabBar
                    .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Maaş Hesabım")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Text("**1480 7332 20**")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            
                            Spacer().frame(height: 4)
                            
                            Text("Bakiyeniz")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack {
                                Text("150.000,00 TL")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }
                            
                            Text("Kullanılabilir Ek Hesap Bakiye: **14.023,00 TL**")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(18)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        HStack(spacing: 12) {
                            QuickActionButton(icon: "arrow.left.arrow.right", title: "Para Aktar") { showLoginAlert = true }
                            QuickActionButton(icon: "creditcard.fill", title: "Ödemeler") { showLoginAlert = true }
                            QuickActionButton(icon: "square.and.arrow.up", title: "IBAN Paylaş") { showLoginAlert = true }
                            QuickActionButton(icon: "ellipsis", title: "Daha Fazlası") { showLoginAlert = true }
                        }
                        .padding(.horizontal, 16)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Piyasa Kurları")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(viewModel.currencies) { currency in
                                        HStack(spacing: 12) {
                                            Text(currency.flagEmoji)
                                                .font(.title2)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(currency.id)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                Text(currency.name)
                                                    .font(.caption2)
                                                    .foregroundColor(.white.opacity(0.6))
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing, spacing: 2) {
                                                Text(String(format: "%.2f TL", currency.sellRate))
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundColor(.white)
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
                                                            .white.opacity(0.6)
                                                )
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        //.glassCard(cornerRadius: 15).opacity(0.6)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            }
        }
        .alert("Hesap Gerekli", isPresented: $showLoginAlert) {
            Button("Giriş Yap") {
                onLoginPromptRequested?()
            }
            Button("Vazgeç", role: .cancel) { }
        } message: {
            Text("Devam etmek için hesabınıza giriş yapın veya yeni bir hesap oluşturun.")
        }
    }
    private var topTabBar: some View {
            HStack(spacing: 0) {
                ForEach(Array(topTabs.enumerated()), id: \.offset) { index, tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTopTab = index
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 18, weight: .medium))

                            Text(tab.title)
                                .font(.system(size: 13, weight: selectedTopTab == index ? .semibold : .regular))

                            Rectangle()
                                .fill(selectedTopTab == index ? Color.white : Color.clear)
                                .frame(height: 2)
                                .padding(.horizontal, 8)
                        }
                        .foregroundColor(selectedTopTab == index ? .white : .white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
}

// MARK: - Subcomponents
struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 45, height: 45)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .blue : .gray)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
        }
    }
}

// MARK: - Color Extension for Hex Support
public extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)
        let r = Double((hexNumber & 0xff0000) >> 16) / 255
        let g = Double((hexNumber & 0x00ff00) >> 8) / 255
        let b = Double(hexNumber & 0x0000ff) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
    }
}

#Preview {
    HomeView()
}
