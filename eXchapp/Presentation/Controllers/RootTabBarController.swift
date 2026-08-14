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
        }
    }

    private func configureTabs() {
        // 1. Sekme: Ana Sayfa
        let homeView = HomeView(
            onLoginPromptRequested: onLoginPromptRequested,
            onRegisterPromptRequested: onRegisterPromptRequested
        )
        let homeHosting = UIHostingController(rootView: homeView)
        homeHosting.tabBarItem = UITabBarItem(title: "Ana Sayfa", image: UIImage(systemName: "house.fill"), selectedImage: UIImage(systemName: "house.fill"))

        // 2. Sekme: Kur Çevirici
        let convertHosting = UIHostingController(rootView: ConvertView())
        convertHosting.tabBarItem = UITabBarItem(title: "Çevirici", image: UIImage(systemName: "arrow.left.arrow.right"), selectedImage: UIImage(systemName: "arrow.left.arrow.right"))

        // 3. Sekme: Profil
        let profileHosting = UIHostingController(rootView: ProfileView())
        profileHosting.tabBarItem = UITabBarItem(title: "Profil", image: UIImage(systemName: "person.fill"), selectedImage: UIImage(systemName: "person.fill"))
        
        // 4. Sekme: Ayarlar
        let settingsHosting = UIHostingController(rootView: SettingsView())
        settingsHosting.tabBarItem = UITabBarItem(title: "Ayarlar", image: UIImage(systemName: "gearshape.fill"), selectedImage: UIImage(systemName: "gearshape.fill"))

        viewControllers = [homeHosting, convertHosting, profileHosting, settingsHosting]
    }

    private func configureAppearance() {
        let appearance = UITabBarAppearance()
        
        // MARK: - Dinamik Tasarım Geçişi
        if FeatureFlags.liquidGlassEnabled {
            // FLAG AÇIK: Tam şeffaf cam efekti
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            appearance.shadowColor = UIColor.white.withAlphaComponent(0.3)
        } else {
            // FLAG KAPALI: Klasik İşCep stili koyu lacivert
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = AppTheme.uiBackgroundDeep
            appearance.shadowColor = .clear
        }

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = AppTheme.uiAccent
        tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.5)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


