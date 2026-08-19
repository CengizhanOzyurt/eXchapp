//
//  LoginView.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 6.08.2026.
//

import SwiftUI
import LocalAuthentication

public struct LoginView: View {
    @AppStorage("liquidGlassEnabled") private var isLiquidGlassEnabled = false
    public var onLoginSuccess: (() -> Void)?
    public var onRegisterTapped: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var emailOrTC: String = ""
    @State private var passwordText: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var rememberMe: Bool = true
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    public init(onLoginSuccess: (() -> Void)? = nil, onRegisterTapped: (() -> Void)? = nil) {
            self.onLoginSuccess = onLoginSuccess
            self.onRegisterTapped = onRegisterTapped
    }
    
    public var body: some View {
        ZStack {
            AppTheme.background(isLiquid: isLiquidGlassEnabled)

            VStack(spacing: 0) {
                
                topBarSection
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        headerSection
                            .padding(.top, 16)
                        
                        inputCardSection
                        
                        actionButtonsSection
                        
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var topBarSection: some View {
        HStack{
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Vazgeç")
                    
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.12))
                .cornerRadius(20)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(isLiquidGlassEnabled ? Color.white.opacity(0.12) : AppTheme.isCepNavy.opacity(0.1))
                    .frame(width: 72, height: 72)
                Image(systemName: "building.columns.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .foregroundColor(isLiquidGlassEnabled ? .white : AppTheme.isCepNavy)
            }
            Text("eXchapp")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))

            Text("Bireysel İnternet Bankacılığı")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
        }
    }
    
    private var inputCardSection: some View {
        VStack(spacing: 16) {
            // T.C. Kimlik / E-Posta Alanı
            VStack(alignment: .leading, spacing: 6) {
                Text("T.C. Kimlik / E-Posta")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                
                HStack(spacing: 10) {
                    Image(systemName: "person")
                        .foregroundColor(isLiquidGlassEnabled ? Color.white.opacity(0.6) : AppTheme.isCepNavy.opacity(0.7))
                    
                    TextField("Giriş yapın", text: $emailOrTC)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                }
                .padding(12)
                .background(isLiquidGlassEnabled ? Color.white.opacity(0.06) : AppTheme.isCepBackgroundGray)
                .cornerRadius(10)
            }
            
            // Bireysel Şifre Alanı
            VStack(alignment: .leading, spacing: 6) {
                Text("Bireysel Şifre")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                
                HStack(spacing: 10) {
                    Image(systemName: "lock")
                        .foregroundColor(isLiquidGlassEnabled ? Color.white.opacity(0.6) : AppTheme.isCepNavy.opacity(0.7))
                    
                    if isPasswordVisible {
                        TextField("Şifreniz", text: $passwordText)
                            .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                    } else {
                        SecureField("••••••", text: $passwordText)
                            .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                    }
                    
                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(isLiquidGlassEnabled ? Color.white.opacity(0.6) : Color.gray)
                    }
                }
                .padding(12)
                .background(isLiquidGlassEnabled ? Color.white.opacity(0.06) : AppTheme.isCepBackgroundGray)
                .cornerRadius(10)
            }
            
            // Beni Hatırla & Şifremi Unuttum
            HStack {
                Button {
                    rememberMe.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                            .foregroundColor(rememberMe ? (isLiquidGlassEnabled ? .cyan : AppTheme.isCepAccent) : AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                        Text("Beni Hatırla")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                    }
                }
                
                Spacer()
                
                Button { } label: {
                    Text("Şifremi Unuttum")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isLiquidGlassEnabled ? .cyan : AppTheme.isCepAccent)
                }
            }
            
            // Hata Mesajı Alanı
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(18)
        .appCard(isLiquid: isLiquidGlassEnabled, cornerRadius: 16)
    }
    
    private var actionButtonsSection: some View {
            VStack(spacing: 12) {
                Button {
                    authenticateUser()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView().tint(isLiquidGlassEnabled ? .black : .white)
                        } else {
                            Text("Giriş Yap")
                                .font(.system(size: 15, weight: .bold))
                        }
                    }
                    .foregroundColor(isLiquidGlassEnabled ? .black : .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(isLiquidGlassEnabled ? Color.white : AppTheme.isCepNavy)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 6, y: 3)
                }

                Button {
                    authenticateWithBiometrics()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "faceid")
                            .font(.system(size: 18))
                        Text("Face ID ile Giriş Yap")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(isLiquidGlassEnabled ? Color.white.opacity(0.10) : Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isLiquidGlassEnabled ? Color.white.opacity(0.18) : Color.black.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(isLiquidGlassEnabled ? 0.0 : 0.04), radius: 4)
                }
            }
        }

        // MARK: - Giriş Doğrulama Mantığı
        private func authenticateUser() {
            guard !emailOrTC.isEmpty, !passwordText.isEmpty else {
                errorMessage = "Lütfen tüm alanları doldurunuz."
                return
            }

            isLoading = true
            errorMessage = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoading = false
                // SQLite Sorgusu
                if let user = DatabaseManager.shared.loginUser(mail: emailOrTC, passwordHash: passwordText) {
                    let session = UserSession(name: user.name, surname: user.surname, mail: user.mail, balance: user.balance)
                    AuthManager.shared.logIn(session)
                    onLoginSuccess?()
                } else {
                    errorMessage = "Giriş bilgileri hatalı veya kullanıcı bulunamadı."
                }
            }
        }

    private func authenticateWithBiometrics() {
            let context = LAContext()
            var error: NSError?

            // 1. Cihazda Face ID / Touch ID donanımı var mı kontrol et
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Hesabınıza güvenli giriş yapmak için Face ID kullanın."

                // 2. iOS Face ID sistem penceresini aç
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            // Biyometri doğrulandı -> Giriş yap
                            let session = UserSession(name: "Cengizhan", surname: "Özyurt", mail: "cengizhan@softtech.com", balance: 150000.0)
                            AuthManager.shared.logIn(session)
                            self.onLoginSuccess?()
                        } else {
                            self.errorMessage = "Face ID doğrulaması başarısız oldu."
                        }
                    }
                }
            } else {
                errorMessage = "Cihazınızda biyometrik doğrulama desteklenmiyor veya kapalı."
            }
        }
}
#Preview {
    LoginView()
}
