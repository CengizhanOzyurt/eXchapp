//
//  RegisterView.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 6.08.2026.
//
import SwiftUI

public struct RegisterView: View {
    public var onRegisterSuccess: (() -> Void)?
    
    // SwiftUI'ın UIKit navigasyon stack'inden bir üst ekrana (Login'e) dönmesini sağlar
    @Environment(\.dismiss) private var dismiss
    
    public init(onRegisterSuccess: (() -> Void)? = nil) {
        self.onRegisterSuccess = onRegisterSuccess
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Üst Kısım: Özel Geri Dönüş Butonu
            VStack {
                HStack {
                    Button(action: {
                        dismiss() // Bir önceki ekran olan LoginView'a geri döner
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
            
            // İçerik
            VStack(spacing: 20) {
                Text("Kayıt Ol Ekranı")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Button("Hesap Oluştur ve Bitir") {
                    onRegisterSuccess?()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .navigationBarHidden(true)
    }
}
#Preview {
    RegisterView()
}
