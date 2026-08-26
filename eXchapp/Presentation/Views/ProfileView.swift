//
//  ProfileView.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 6.08.2026.
//

import SwiftUI

public struct ProfileView: View {
    @AppStorage("liquidGlassEnabled") private var isLiquidGlassEnabled = false
    @StateObject private var authManager = AuthManager.shared
    
    @State private var userHoldings: [String: Double] = ["USD": 150.0, "EUR": 75.50]
    
    public var onLoginPromptRequested: (() -> Void)?
    public var onRegisterPromptRequested: (() -> Void)?
    
    public init(onLoginPromptRequested: (() -> Void)? = nil, onRegisterPromptRequested: (() -> Void)? = nil) {
        self.onLoginPromptRequested = onLoginPromptRequested
        self.onRegisterPromptRequested = onRegisterPromptRequested
    }

    public var body: some View {
        
        ZStack {
            AppTheme.background(isLiquid: isLiquidGlassEnabled)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    if authManager.isLoggedIn, let user = authManager.currentUser {
                        
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(true ? Color.white.opacity(0.12) : AppTheme.isCepNavy.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .foregroundColor(true ? .white : AppTheme.isCepNavy)
                            }
                            .padding(.top, 20)

                            VStack(spacing: 4) {
                                Text("\(user.name) \(user.surname)")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary(isLiquid: true))

                                Text(user.mail)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textSecondary(isLiquid: true))
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Varlıklarım & Cüzdan Özeti")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                                .padding(.bottom, 4)
                            
                            HStack {
                                Image(systemName: "turkishlirasign.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                Text("Kullanılabilir Bakiye")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                                Spacer()
                                Text(String(format: "%.2f ₺", user.balance))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                            }
                            
                            Divider().padding(.vertical, 4)
                            
                            
                            if !user.holdings.isEmpty {
                                ForEach(user.holdings.sorted(by: { $0.key < $1.key }), id: \.key) { holding in
                                    if holding.value > 0 {
                                        HStack {
                                            Text(holding.key)
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                                            Spacer()
                                            Text(String(format: "%.2f %@", holding.value, holding.key))
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(isLiquidGlassEnabled ? .cyan : AppTheme.isCepNavy)
                                        }
                                        .padding(.vertical, 2)
                                    }
                                }
                            } else {
                                HStack {
                                    Text("Henüz farklı bir döviz varlığınız bulunmuyor.")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                                    Spacer()
                                }
                            }
                        }
                        .padding(18)
                        .appCard(isLiquid: isLiquidGlassEnabled, cornerRadius: 16)
                        .padding(.horizontal, 16)

                        Button {
                            withAnimation {
                                authManager.logOut()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Oturumu Kapat")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)

                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.badge.exclamationmark")
                                .font(.system(size: 60))
                                .foregroundColor(isLiquidGlassEnabled ? .white : AppTheme.isCepNavy)
                                .padding(.top, 30)

                            Text("Profilinizi Görüntüleyin")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))

                            Text("İşlem ve bakiye yönetimi yapmak için giriş yapmanız gerekmektedir.")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)

                            VStack(spacing: 12) {
                                Button {
                                    onLoginPromptRequested?()
                                } label: {
                                    Text("Giriş Yap")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(isLiquidGlassEnabled ? .black : .white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(isLiquidGlassEnabled ? Color.white : AppTheme.isCepButton)
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding(24)
                        .appCard(isLiquid: isLiquidGlassEnabled)
                        .padding(.horizontal, 16)
                        .padding(.top, 40)
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
