//
//  SettingsView.swift
//  eXchapp
//
//  Created by Cengizhan Özyurt on 14.08.2026.
//

import SwiftUI
import LocalAuthentication

public struct SettingsView: View {
    @AppStorage("liquidGlassEnabled") private var isLiquidGlassEnabled = false
    @StateObject private var authManager = AuthManager.shared
    
    @State private var isFaceIDEnabled: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0B4DB7"), Color(hex: "082870"), Color(hex: "04123A")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Ayarlar")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Liquid Glass Efekti")
                            .font(.headline)
                            .foregroundColor(isLiquidGlassEnabled ? .white : .black)
                        
                        Text(isLiquidGlassEnabled ? "Modern şeffaf cam görünümü aktif." : "Beyaz tasarım aktif.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                    Toggle("", isOn: $isLiquidGlassEnabled)
                        .labelsHidden()
                }
                .padding()
                .appCard(isLiquid: isLiquidGlassEnabled)
                .padding(.horizontal)
                .onChange(of: isLiquidGlassEnabled) { newValue in
                    NotificationCenter.default.post(name: NSNotification.Name("ThemeChangedNotification"), object: nil)
                }
                
                if authManager.isLoggedIn, let user = authManager.currentUser {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Face ID ile Hızlı Giriş")
                                .font(.headline)
                                .foregroundColor(isLiquidGlassEnabled ? .white : .black)
                            
                            Text("Bu hesap için yüz tanımayı etkinleştir.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: {
                                return UserDefaults.standard.bool(forKey: "isFaceIDEnabled_\(user.mail)")
                            },
                            set: { newValue in
                                if newValue {
                                    verifyAndEnableFaceID(for: user.mail)
                                } else {
                                    disableFaceID(for: user.mail)
                                }
                            }
                        ))
                        .labelsHidden()
                    }
                    .padding()
                    .appCard(isLiquid: isLiquidGlassEnabled)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Güvenlik"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
        }
    }
    
    private func verifyAndEnableFaceID(for email: String) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Hesabınızı Face ID ile eşleştirmek için kimliğinizi doğrulayın."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        UserDefaults.standard.set(email, forKey: "savedUserEmailForFaceID")
                        UserDefaults.standard.set(true, forKey: "isFaceIDEnabled_\(email)")
                        alertMessage = "Face ID bu hesap için başarıyla etkinleştirildi."
                        showAlert = true
                    } else {
                        alertMessage = "Face ID doğrulaması başarısız oldu, eşleştirilemedi."
                        showAlert = true
                    }
                }
            }
        } else {
            alertMessage = "Cihazınızda Face ID desteklenmiyor veya izin verilmemiş."
            showAlert = true
        }
    }
    
    private func disableFaceID(for email: String) {
        UserDefaults.standard.set(false, forKey: "isFaceIDEnabled_\(email)")
        if UserDefaults.standard.string(forKey: "savedUserEmailForFaceID") == email {
            UserDefaults.standard.removeObject(forKey: "savedUserEmailForFaceID")
        }
        alertMessage = "Face ID bu hesap için devre dışı bırakıldı."
        showAlert = true
    }
}

#Preview {
    SettingsView()
}
