//
//  SettingsView.swift
//  eXchapp
//
//  Created by Cengizhan Özyurt on 14.08.2026.
//

import SwiftUI

public struct SettingsView: View {
    @AppStorage("liquidGlassEnabled") private var isLiquidGlassEnabled = false
    
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
                
                // ÇÖZÜM: Yazılar ve Toggle birbirinden ayrıldı
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Liquid Glass Efekti")
                            .font(.headline)
                            .foregroundColor(isLiquidGlassEnabled ? .black : .black)
                        
                        Text(isLiquidGlassEnabled ? "Modern şeffaf cam görünümü aktif." : "Beyaz tasarım aktif.")
                            .font(.caption)
                            .foregroundColor(isLiquidGlassEnabled ? .gray : .gray)
                    }
                    Spacer()
                    
                    Toggle("", isOn: $isLiquidGlassEnabled)
                        .labelsHidden() // Toggle'ın kendi görünmez etiketini sildik
                }
                .padding()
                .conditionalGlassBackground(cornerRadius: 16)
                .padding(.horizontal)
                .onChange(of: isLiquidGlassEnabled) { newValue in
                                    NotificationCenter.default.post(name: NSNotification.Name("ThemeChangedNotification"), object: nil)
                                }
                
                Spacer()
            }
        }
    }
}
#Preview {
    SettingsView()
}
