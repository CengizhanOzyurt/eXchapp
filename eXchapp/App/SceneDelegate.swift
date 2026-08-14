//
//  SceneDelegate.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 6.08.2026.
//

//
//  SceneDelegate.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 6.08.2026.
//

import UIKit
import SwiftUI

public class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    public var window: UIWindow?
    private var navigationController: UINavigationController?
    
    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions){
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let rootTabBar = RootTabBarController()
        
        rootTabBar.onLoginPromptRequested = { [weak self] in
            self?.navigateToLogin()
        }
        
        rootTabBar.onRegisterPromptRequested = { [weak self] in
            self?.navigateToRegister()
        }
        
        let navController = UINavigationController(rootViewController: rootTabBar)
        
        navController.setNavigationBarHidden(true, animated: false)
        
        self.navigationController = navController
        window.rootViewController = navController
        
        // HATANIN DÜZELTİLDİĞİ YER:
        self.window = window
        
        window.makeKeyAndVisible()
    }
    
    private func navigateToLogin() {
        let loginView = LoginView(
            onLoginSuccess: { [weak self] in
                // Giriş başarılı olunca en başa (Ana Sayfaya) dön
                self?.navigationController?.popToRootViewController(animated: true)
            },
            onRegisterTapped: { [weak self] in
                // Loginden Register'a geçiş (Stack'e yeni ekran eklenir)
                self?.navigateToRegister()
            }
        )
        
        let hostingController = UIHostingController(rootView: loginView)
        // Login ekranına giderken üst barı gizli tutuyoruz ki kendi özel tasarımımız görünsün
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    private func navigateToRegister(){
        let registerView = RegisterView(
            onRegisterSuccess: { [weak self] in
                // Kayıt başarılı olunca en başa (Ana Sayfaya) dön
                self?.navigationController?.popToRootViewController(animated: true)
            }
        )
        
        let hostingController = UIHostingController(rootView: registerView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
}
