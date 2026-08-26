//
//  LiquidGlassModifier.swift
//  eXchapp
//
//  Created by Cengizhan Özyurt on 13.08.2026.
//
import SwiftUI

// MARK: - Conditional Transparent Glass / İşCep White Modifier
public struct ConditionalGlassModifier: ViewModifier {
    let cornerRadius: CGFloat
    
    public func body(content: Content) -> some View {
        if FeatureFlags.liquidGlassEnabled {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.white.opacity(0.15))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.white)
                )
        }
    }
}

public extension View {
    func conditionalGlassBackground(cornerRadius: CGFloat = 24) -> some View {
        self.modifier(ConditionalGlassModifier(cornerRadius: cornerRadius))
    }
}
