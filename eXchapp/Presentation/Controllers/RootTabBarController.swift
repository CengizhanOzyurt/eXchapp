//
//  RootTabBarController.swift
//  eXchapp
//
//  Created by Cengizhan Özyurt on 14.08.2026.
//

import UIKit
import SwiftUI

/// Uygulamanın UIKit iskeleti. Sekmelerin her biri SwiftUI ile yazılmış
/// bir ekranı `UIHostingController` üzerinden barındırır.
public final class RootTabBarController: UITabBarController {

    public var onLoginPromptRequested: (() -> Void)?
    public var onRegisterPromptRequested: (() -> Void)?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        configureTabs()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChange),
            name: FeatureFlags.themeChangedNotification,
            object: nil
        )
    }
    
    @objc private func handleThemeChange() {
        UIView.animate(withDuration: 0.3) {
            self.configureAppearance()
            self.tabBar.layoutIfNeeded()
        }
    }

    private func configureTabs() {
        let homeView = HomeView(
            onLoginPromptRequested: onLoginPromptRequested,
            onRegisterPromptRequested: onRegisterPromptRequested
        )
        let homeHosting = UIHostingController(rootView: homeView)
        homeHosting.tabBarItem = UITabBarItem(title: "Ana Sayfa", image: UIImage(systemName: "house.fill"), selectedImage: UIImage(systemName: "house.fill"))

        let convertHosting = UIHostingController(rootView: ConvertView())
        convertHosting.tabBarItem = UITabBarItem(title: "Çevirici", image: UIImage(systemName: "arrow.left.arrow.right"), selectedImage: UIImage(systemName: "arrow.left.arrow.right"))

        let profileHosting = UIHostingController(rootView: ProfileView())
        profileHosting.tabBarItem = UITabBarItem(title: "Profil", image: UIImage(systemName: "person.fill"), selectedImage: UIImage(systemName: "person.fill"))
        
        let settingsHosting = UIHostingController(rootView: SettingsView())
        settingsHosting.tabBarItem = UITabBarItem(title: "Ayarlar", image: UIImage(systemName: "gearshape.fill"), selectedImage: UIImage(systemName: "gearshape.fill"))

        viewControllers = [homeHosting, convertHosting, profileHosting, settingsHosting]
    }

    private func configureAppearance() {
        let appearance = UITabBarAppearance()
        
        // MARK: - Dinamik Tasarım Geçişi
        let isLiquidGlass = FeatureFlags.liquidGlassEnabled
        
        if isLiquidGlass {
            // FLAG AÇIK: Tam şeffaf cam efekti
            appearance.configureWithTransparentBackground()
            appearance.backgroundEffect = nil
            appearance.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            appearance.shadowColor = UIColor.white.withAlphaComponent(0.3)
            configureItemAppearance(
                appearance,
                selectedColor: .white,
                normalColor: UIColor.white.withAlphaComponent(0.5)
            )
            
            tabBar.isTranslucent = true
            tabBar.backgroundColor = .clear
            tabBar.barTintColor = nil
            tabBar.backgroundImage = nil
            tabBar.shadowImage = nil
            tabBar.isOpaque = false
            tabBar.tintColor = .white
            tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.5)
        } else {
            // FLAG KAPALI: Aynı tab bar formu, tam opak beyaz zemin (şeffaflık yok)
            appearance.configureWithOpaqueBackground()
            appearance.backgroundEffect = nil
            appearance.backgroundColor = .white
            appearance.shadowColor = UIColor.lightGray.withAlphaComponent(0.3)
            configureItemAppearance(
                appearance,
                selectedColor: AppTheme.uiAccent,
                normalColor: .gray
            )
            
            // Beyaz zemin üzerinde seçili sekme MAVİ (AppTheme.uiAccent), diğerleri GRİ
            tabBar.isTranslucent = false
            tabBar.backgroundColor = .white
            tabBar.barTintColor = .white
            tabBar.backgroundImage = nil
            tabBar.shadowImage = nil
            tabBar.isOpaque = true
            tabBar.tintColor = AppTheme.uiAccent
            tabBar.unselectedItemTintColor = .gray
        }

        // Ayarları sisteme uygula
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.items?.forEach { item in
            item.standardAppearance = appearance
            item.scrollEdgeAppearance = appearance
        }
        tabBar.setNeedsLayout()
        tabBar.setNeedsDisplay()
    }

    private func configureItemAppearance(
        _ appearance: UITabBarAppearance,
        selectedColor: UIColor,
        normalColor: UIColor
    ) {
        let itemAppearances = [
            appearance.stackedLayoutAppearance,
            appearance.inlineLayoutAppearance,
            appearance.compactInlineLayoutAppearance
        ]

        itemAppearances.forEach { itemAppearance in
            itemAppearance.normal.iconColor = normalColor
            itemAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]
            itemAppearance.selected.iconColor = selectedColor
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
