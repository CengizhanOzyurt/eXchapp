//
//  ProfileView.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 6.08.2026.
//

import SwiftUI

public struct ProfileView: View {
    
    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0B4DB7"), Color(hex: "082870"), Color(hex: "04123A")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            Text("Profil Ekranı Yakında")
                .font(.title2)
                .foregroundColor(AppTheme.textSecondary)
        }
    }
}
#Preview {
    ProfileView()
}
