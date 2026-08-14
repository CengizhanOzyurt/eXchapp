//
//  LoginView.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 6.08.2026.
//

import SwiftUI

public struct LoginView: View {
    public var onLoginSuccess: (() -> Void)?
    public var onRegisterTapped: (() -> Void)?
    
    // UIKit navigation controller'a erişmek için çevre birimini kullanıyoruz
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(
                colors: [Color(hex: "0B4DB7"), Color(hex: "082870"), Color(hex: "04123A")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            // Özel Geri Dönüş Butonu (Sol Üst Köşe)
            VStack {
                HStack {
                    Button(action: {
                        dismiss() // Bir önceki ekrana (HomeView) geri döner
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Geri")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                
                Spacer()
            }
            
            Text("Geçici Giriş Ekranı")
                .foregroundColor(.white)
        }
        .navigationBarHidden(true) // UIKit barı gizli kalmaya devam eder
    }
}
