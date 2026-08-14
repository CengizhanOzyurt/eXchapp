//
//  ConvertView.swift
//  eXchapp
//
//  Created by Cengizhan Özyurt on 14.08.2026.
//

import SwiftUI

public struct ConvertView: View {
    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0B4DB7"), Color(hex: "082870"), Color(hex: "04123A")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            Text("Kur Çevirici Yakında")
                .font(.title2)
                .foregroundColor(AppTheme.textSecondary)
        }
    }
}
#Preview {
    ConvertView()
}
