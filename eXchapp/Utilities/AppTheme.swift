//
//  AppTheme.swift
//  eXchapp
//
//  Created by Cengizhan Özyurt on 13.08.2026.
//

import SwiftUI
import UIKit

public enum AppTheme {
    public static let backgroundDeep = Color(red: 0.03, green: 0.07, blue: 0.20)
    public static let backgroundMid = Color(red: 0.06, green: 0.16, blue: 0.42)
    public static let backgroundBright = Color(red: 0.11, green: 0.30, blue: 0.72)

    public static let cardSurface = Color.white.opacity(0.08)
    public static let cardStroke = Color.white.opacity(0.14)

    public static let accent = Color(red: 0.18, green: 0.47, blue: 0.95)
    public static let textPrimary = Color.white
    public static let textSecondary = Color.white.opacity(0.65)

    public static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [backgroundDeep, backgroundMid, backgroundBright],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public static let uiBackgroundDeep = UIColor(backgroundDeep)
    public static let uiAccent = UIColor(accent)
}

public struct GlassCardModifier: ViewModifier {
    public var cornerRadius: CGFloat = 20

    public func body(content: Content) -> some View {
        if FeatureFlags.liquidGlassEnabled {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.clear)
                )
                .modifier(LiquidGlassBackground(cornerRadius: cornerRadius))
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppTheme.cardSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(AppTheme.cardStroke, lineWidth: 1)
                        )
                )
        }
    }
}

private struct LiquidGlassBackground: ViewModifier {
    let cornerRadius: CGFloat

    public func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

public extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}
