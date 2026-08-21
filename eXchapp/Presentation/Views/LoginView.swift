import SwiftUI
import LocalAuthentication

public struct LoginView: View {
    @AppStorage("liquidGlassEnabled") private var isLiquidGlassEnabled = false
    public var onLoginSuccess: (() -> Void)?
    public var onRegisterTapped: (() -> Void)?
    public var onDismissRequested: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var emailOrTC: String = ""
    @State private var passwordText: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var rememberMe: Bool = true
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    public init(
        onLoginSuccess: (() -> Void)? = nil,
        onRegisterTapped: (() -> Void)? = nil,
        onDismissRequested: (() -> Void)? = nil
    ) {
        self.onLoginSuccess = onLoginSuccess
        self.onRegisterTapped = onRegisterTapped
        self.onDismissRequested = onDismissRequested
    }
    
    public var body: some View {
        ZStack {
            AppTheme.background(isLiquid: false)

            VStack(spacing: 0) {
                topBarSection
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                            .padding(.top, 16)
                        
                        inputCardSection
                        actionButtonsSection
                        
                        Spacer().frame(height: 10)
                        footerRegisterSection
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
                    Text("Vazgeç")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textTertiary(isLiquid: false))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(false ? Color.white.opacity(0.12) : Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(false ? 0.0 : 0.05), radius: 4)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            Spacer()
            Text("eXchapp")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private var inputCardSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("T.C. Kimlik / E-Posta")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary(isLiquid: false))
                
                HStack(spacing: 10) {
                    Image(systemName: "person")
                        .foregroundColor(false ? Color.white.opacity(0.6) : AppTheme.isCepNavy.opacity(0.7))
                    
                    TextField("Giriş yapın", text: $emailOrTC)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(AppTheme.textSecondary(isLiquid: false))
                }
                .padding(12)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Bireysel Şifre")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary(isLiquid: false))
                
                HStack(spacing: 10) {
                    Image(systemName: "lock")
                        .foregroundColor(false ? Color.white.opacity(0.6) : AppTheme.isCepNavy.opacity(0.7))
                    
                    if isPasswordVisible {
                        TextField("Şifreniz", text: $passwordText)
                            .foregroundColor(AppTheme.textPrimary(isLiquid: false))
                    } else {
                        SecureField("••••••", text: $passwordText)
                            .foregroundColor(AppTheme.textPrimary(isLiquid: false))
                    }
                    
                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(false ? Color.white.opacity(0.6) : Color.gray)
                    }
                }
                .padding(12)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)
            }
            
            HStack {
                Button {
                    rememberMe.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                            .foregroundColor(rememberMe ? (false ? .cyan : AppTheme.isCepAccent) : AppTheme.textSecondary(isLiquid: false))
                        Text("Beni Hatırla")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textPrimary(isLiquid: false))
                    }
                }
                
                Spacer()
                
                Button { } label: {
                    Text("Şifremi Unuttum")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isLiquidGlassEnabled ? .cyan : AppTheme.isCepAccent)
                }
            }
            
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
                .background(isLiquidGlassEnabled ? Color.white : AppTheme.isCepButton)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 6, y: 3)
            }

            Button {
                authenticateWithBiometrics()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "faceid")
                        .font(.system(size: 18))
                        .foregroundColor(Color.green)
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

    private var footerRegisterSection: some View {
        HStack(spacing: 4) {
            Text("Henüz hesabınız yok mu?")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textWhite(isLiquid: isLiquidGlassEnabled))

            Button {
                onRegisterTapped?()
            } label: {
                Text("Kayıt Ol")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(isLiquidGlassEnabled ? .cyan : AppTheme.isCepAccent)
            }
        }
    }

    private func authenticateUser() {
        guard !emailOrTC.isEmpty, !passwordText.isEmpty else {
            errorMessage = "Lütfen tüm alanları doldurunuz."
            return
        }

        isLoading = true
        errorMessage = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
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

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Hesabınıza güvenli giriş yapmak için Face ID kullanın."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
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
