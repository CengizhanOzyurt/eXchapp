//
//  SplashView.swift
//  eXchapp
//
//  Created by Cengizhan Özyurt on 26.08.2026.
//

import SwiftUI

public struct SplashView: View {
    public var onFinished: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var glowOpacity: Double = 0.2
    
    public init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
    }

    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "020817"), Color(hex: "0B2545"), Color(hex: "04123A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color(hex: "0066FF"))
                .frame(width: 220, height: 220)
                .blur(radius: 60)
                .opacity(glowOpacity)

            VStack(spacing: 24) {
                ZStack {
                    

                    Image("eXchappLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400, height: 400)
                }
                .scaleEffect(scale)
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0.5)) {
                self.scale = 1.0
                self.opacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                self.glowOpacity = 0.6
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    onFinished()
                }
            }
        }
    }
}
