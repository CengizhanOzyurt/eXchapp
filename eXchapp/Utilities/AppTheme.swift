//
//  AppTheme.swift
//  eXchapp
//
//  Created by Cengizhan Özyurt on 13.08.2026.
//

import SwiftUI
import UIKit

// MARK: - Color Hex Extension
public extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)
        let r = Double((hexNumber & 0xff0000) >> 16) / 255
        let g = Double((hexNumber & 0x00ff00) >> 8) / 255
        let b = Double(hexNumber & 0x0000ff) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
    }
}

public enum AppTheme {
    public static let isCepButton = Color(hex: "0D6CB5")
    public static let isCepNavy = Color(hex: "082870")
    public static let isCepBlue = Color(hex: "0B4DB7")
    public static let isCepDark = Color(hex: "04123A")
    public static let isCepBackgroundGray = Color(hex: "F4F6F9")
    public static let isCepAccent = Color(hex: "0052CC")
    public static let isCepWhite = Color(hex: "ffffff")
    
    public static let uiAccent = UIColor(isCepAccent)
    public static let uiNavy = UIColor(isCepNavy)
    
    // MARK: - Dynamic Background
    @ViewBuilder
    public static func background(isLiquid: Bool) -> some View {
        if isLiquid {
            LinearGradient(
                colors: [isCepBlue, isCepNavy, isCepDark],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        } else {
            LinearGradient(
                colors: [isCepBlue, isCepNavy, isCepDark],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
    

    public static func textPrimary(isLiquid: Bool) -> Color {
        isLiquid ? .white : Color(hex: "000000")
    }
    
    public static func textSecondary(isLiquid: Bool) -> Color {
        isLiquid ? Color.white.opacity(0.65) : Color(hex: "6C757D")
    }
    public static func textTertiary(isLiquid: Bool) -> Color {
        isLiquid ? .white : Color(hex: "0E0B70")
    }
    public static func textWhite(isLiquid: Bool) -> Color {
        isLiquid ? .white : Color(hex: "FFFFFF")
    }
    
    public static func barForeground(isLiquid: Bool) -> Color {
        isLiquid ? .white : .white
    }
}

public struct DynamicCardModifier: ViewModifier {
    let isLiquid: Bool
    let cornerRadius: CGFloat

    public func body(content: Content) -> some View {
        if isLiquid {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.08), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.45),
                                    Color.white.opacity(0.10),
                                    Color.clear,
                                    Color.white.opacity(0.20)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
    }
}

public extension View {
    func appCard(isLiquid: Bool, cornerRadius: CGFloat = 16) -> some View {
        modifier(DynamicCardModifier(isLiquid: isLiquid, cornerRadius: cornerRadius))
    }
}
