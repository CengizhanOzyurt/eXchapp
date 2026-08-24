//
//  RootTabBarController.swift
//  eXchapp
//
//  Created by Cengizhan Özyurt on 14.08.2026.
//

import UIKit
import SwiftUI

public final class RootTabBarController: UITabBarController {

    public var onLoginPromptRequested: (() -> Void)?
    public var onRegisterPromptRequested: (() -> Void)?

    public init(
        onLoginPromptRequested: (() -> Void)? = nil,
        onRegisterPromptRequested: (() -> Void)? = nil
    ) {
        self.onLoginPromptRequested = onLoginPromptRequested
        self.onRegisterPromptRequested = onRegisterPromptRequested
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
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

        let profileView = ProfileView(
            onLoginPromptRequested: onLoginPromptRequested,
            onRegisterPromptRequested: onRegisterPromptRequested
        )
        let profileHosting = UIHostingController(rootView: profileView)
        profileHosting.tabBarItem = UITabBarItem(title: "Profil", image: UIImage(systemName: "person.fill"), selectedImage: UIImage(systemName: "person.fill"))
        
        let settingsHosting = UIHostingController(rootView: SettingsView())
        settingsHosting.tabBarItem = UITabBarItem(title: "Ayarlar", image: UIImage(systemName: "gearshape.fill"), selectedImage: UIImage(systemName: "gearshape.fill"))

        viewControllers = [homeHosting, convertHosting, profileHosting, settingsHosting]
    }

    private func configureAppearance() {
        let appearance = UITabBarAppearance()
        
        let isLiquidGlass = FeatureFlags.liquidGlassEnabled
        
        if isLiquidGlass {
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
            // FLAG KAPALI: Eski iOS tarzı, tamamen düz, opak ve beyaz tab bar
            appearance.configureWithOpaqueBackground()
            appearance.backgroundEffect = nil
            appearance.backgroundColor = .white
            appearance.shadowColor = UIColor.systemGray5
            
            appearance.selectionIndicatorTintColor = .clear
            
            configureItemAppearance(
                appearance,
                selectedColor: AppTheme.uiAccent,
                normalColor: .gray
            )
            
            tabBar.isTranslucent = false
            tabBar.isOpaque = true
            tabBar.backgroundColor = .white
            tabBar.barTintColor = .white
            tabBar.tintColor = AppTheme.uiAccent
            tabBar.unselectedItemTintColor = .gray
            
            // 💧 BALONCUK İMAJINI TEMİZLER
            tabBar.selectionIndicatorImage = UIImage()
            tabBar.backgroundImage = UIImage()
            tabBar.shadowImage = UIImage()
        }

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        tabBar.items?.forEach { item in
            item.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                item.scrollEdgeAppearance = appearance
            }
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
            // Hatalı özellikler (backgroundColor) buradan kaldırıldı.
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
