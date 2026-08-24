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
                        // MARK: - GİRİŞ YAPILMIŞSA: KULLANICI PROFİLİ
                        VStack(spacing: 16) {
                            ZStack {
                                
                                Circle()
                                    .fill(isLiquidGlassEnabled ? Color.white.opacity(0.12) : AppTheme.isCepNavy.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .foregroundColor(isLiquidGlassEnabled ? .white : AppTheme.isCepNavy)
                            }
                            .padding(.top, 20)

                            VStack(spacing: 4) {
                                Text("\(user.name) \(user.surname)")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))

                                Text(user.mail)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Hesap Özeti")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                            
                            HStack {
                                Text("Varlık Toplamı")
                                    .font(.system(size: 15))
                                    .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                                Spacer()
                                Text(String(format: "%.2f TL", user.balance))
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(isLiquidGlassEnabled ? .cyan : AppTheme.isCepNavy)
                            }
                        }
                        .padding(18)
                        .appCard(isLiquid: isLiquidGlassEnabled, cornerRadius: 16)
                        .padding(.horizontal, 16)

                        // Çıkış Yap Butonu
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
                        // MARK: - GİRİŞ YAPILMAMIŞSA: MİSAFİR GİRİŞ KARTI
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
