//
//  RegisterView.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 6.08.2026.
//
import SwiftUI

public struct RegisterView: View {
    @AppStorage("liquidGlassEnabled") private var isLiquidGlassEnabled = false
    public var onRegisterSuccess: (() -> Void)?
    public var onDismissRequested: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var birthDate: Date = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
    @State private var selectedCountry: String = "Türkiye 🇹🇷"
    @State private var email: String = ""
    @State private var passwordText: String = ""
    @State private var confirmPasswordText: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var termsAccepted: Bool = false
    
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    private let countries: [String] = [
        "Türkiye 🇹🇷", "Almanya 🇩🇪", "ABD 🇺🇸", "İngiltere 🇬🇧",
        "Hollanda 🇳🇱", "Fransa 🇫🇷", "İsviçre 🇨🇭", "Azerbaycan 🇦🇿"
    ]

    public init(onRegisterSuccess: (() -> Void)? = nil, onDismissRequested: (() -> Void)? = nil) {
        self.onRegisterSuccess = onRegisterSuccess
        self.onDismissRequested = onDismissRequested
    }

    public var body: some View {
        ZStack {
            AppTheme.background(isLiquid: false)

            VStack(spacing: 0) {
                topBarSection

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerSection
                            .padding(.top, 8)

                        formSection
                        actionSection

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var topBarSection: some View {
        HStack {
            Button(action: {
                if let onDismissRequested = onDismissRequested {
                    onDismissRequested()
                } else {
                    dismiss()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Geri")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textTertiary(isLiquid: isLiquidGlassEnabled))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isLiquidGlassEnabled ? Color.white.opacity(0.12) : Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(isLiquidGlassEnabled ? 0.0 : 0.05), radius: 4)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Yeni Hesap Açın")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
        }
    }

    private var formSection: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Ad")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                
                HStack(spacing: 10) {
                    Image(systemName: "person")
                        .foregroundColor(false ? Color.white.opacity(0.6) : AppTheme.isCepNavy.opacity(0.7))
                    TextField("Adınız", text: $name)
                        .disableAutocorrection(true)
                        .foregroundColor(AppTheme.textPrimary(isLiquid: false))
                }
                .padding(12)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Soyad")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary(isLiquid: false))
                
                HStack(spacing: 10) {
                    Image(systemName: "person")
                        .foregroundColor(false ? Color.white.opacity(0.6) : AppTheme.isCepNavy.opacity(0.7))
                    TextField("Soyadınız", text: $surname)
                        .disableAutocorrection(true)
                        .foregroundColor(AppTheme.textPrimary(isLiquid: false))
                }
                .padding(12)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Doğum Tarihi")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary(isLiquid: false))

                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(false ? Color.white.opacity(0.6) : AppTheme.isCepNavy.opacity(0.7))
                        
                        DatePicker(
                            "",
                            selection: $birthDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .environment(\.colorScheme, false ? .dark : .light)
                        .tint(false ? .cyan : AppTheme.isCepAccent)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Ülke")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary(isLiquid: false))

                    Menu {
                        ForEach(countries, id: \.self) { country in
                            Button(country) {
                                selectedCountry = country
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(false ? Color.white.opacity(0.6) : AppTheme.isCepNavy.opacity(0.7))
                            
                            Text(selectedCountry)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary(isLiquid: false))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                        }
                        .padding(.horizontal, 10)
                        .frame(height: 48)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("E-Posta Adresi")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary(isLiquid: false))

                HStack(spacing: 10) {
                    Image(systemName: "envelope")
                        .foregroundColor(false ? Color.white.opacity(0.6) : AppTheme.isCepNavy.opacity(0.7))
                    TextField("E-mail", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .foregroundColor(AppTheme.textPrimary(isLiquid: false))
                }
                .padding(12)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Şifre")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary(isLiquid: false))

                HStack(spacing: 10) {
                    Image(systemName: "lock")
                        .foregroundColor(false ? Color.white.opacity(0.6) : AppTheme.isCepNavy.opacity(0.7))

                    if isPasswordVisible {
                        TextField("••••••", text: $passwordText)
                            .foregroundColor(AppTheme.textPrimary(isLiquid: false))
                    } else {
                        SecureField("••••••", text: $passwordText)
                            .foregroundColor(AppTheme.textPrimary(isLiquid: false))
                    }

                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye.fill")
                            .foregroundColor(false ? Color.white.opacity(0.6) : Color.gray)
                    }
                }
                .padding(12)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Şifre Tekrar")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary(isLiquid: false))

                HStack(spacing: 10) {
                    Image(systemName: "lock.rotation")
                        .foregroundColor(false ? Color.white.opacity(0.6) : AppTheme.isCepNavy.opacity(0.7))

                    if isPasswordVisible {
                        TextField("••••••", text: $confirmPasswordText)
                            .foregroundColor(AppTheme.textPrimary(isLiquid: false))
                    } else {
                        SecureField("••••••", text: $confirmPasswordText)
                            .foregroundColor(AppTheme.textPrimary(isLiquid: false))
                    }
                }
                .padding(12)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)
            }

            Button {
                termsAccepted.toggle()
            } label: {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: termsAccepted ? "checkmark.square.fill" : "square")
                        .foregroundColor(termsAccepted ? (false ? .cyan : AppTheme.isCepAccent) : AppTheme.textSecondary(isLiquid: false))
                        .font(.system(size: 16))
                    
                    Text("Bankacılık Sözleşmesi ve KVKK Aydınlatma Metni'ni okudum, onaylıyorum.")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textPrimary(isLiquid: false))
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.top, 4)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(18)
        .appCard(isLiquid: false, cornerRadius: 16)
    }

    private var actionSection: some View {
        Button {
            registerUser()
        } label: {
            HStack {
                if isLoading {
                    ProgressView().tint(false ? .black : .white)
                } else {
                    Text("Hesabı Oluştur ve Giriş Yap")
                        .font(.system(size: 15, weight: .bold))
                }
            }
            .foregroundColor(false ? .black : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(false ? Color.white : AppTheme.isCepButton)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 6, y: 3)
        }
    }

    private func registerUser() {
        guard !name.isEmpty, !surname.isEmpty, !email.isEmpty, !passwordText.isEmpty else {
            errorMessage = "Lütfen tüm alanları eksiksiz doldurunuz."
            return
        }

        let calculatedAge = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 18
        
        guard calculatedAge >= 18 else {
            errorMessage = "Bireysel hesap açabilmek için en az 18 yaşında olmalısınız."
            return
        }

        guard passwordText == confirmPasswordText else {
            errorMessage = "Girilen şifreler birbiriyle eşleşmiyor."
            return
        }

        guard termsAccepted else {
            errorMessage = "Lütfen sözleşmeyi onaylayınız."
            return
        }

        isLoading = true
        errorMessage = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isLoading = false
            
            let initialBalance = 50000.0
            let success = DatabaseManager.shared.registerUser(
                name: name,
                surname: surname,
                mail: email,
                age: calculatedAge,
                passwordHash: passwordText,
                initialBalance: initialBalance
            )

            if success {
                let newSession = UserSession(name: name, surname: surname, mail: email, balance: initialBalance)
                AuthManager.shared.logIn(newSession)
                onRegisterSuccess?()
            } else {
                errorMessage = "Bu e-posta adresi ile kayıtlı bir hesap zaten var."
            }
        }
    }
}

#Preview {
    RegisterView()
}
