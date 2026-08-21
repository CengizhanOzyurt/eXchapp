import UIKit
import SwiftUI

public class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    public var window: UIWindow?
    private var navigationController: UINavigationController?
    
    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions){
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let rootTabBar = RootTabBarController(
            onLoginPromptRequested: { [weak self] in
                self?.navigateToLogin()
            },
            onRegisterPromptRequested: { [weak self] in
                self?.navigateToRegister()
            }
        )
        
        let navController = UINavigationController(rootViewController: rootTabBar)
        navController.setNavigationBarHidden(true, animated: false)
        
        self.navigationController = navController
        window.rootViewController = navController
        self.window = window
        
        window.makeKeyAndVisible()
    }
    
    private func navigateToLogin() {
        let loginView = LoginView(
            onLoginSuccess: { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            },
            onRegisterTapped: { [weak self] in
                self?.navigateToRegister()
            },
            onDismissRequested: { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            }
        )
        
        let hostingController = UIHostingController(rootView: loginView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    private func navigateToRegister(){
        let registerView = RegisterView(
            onRegisterSuccess: { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            },
            onDismissRequested: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        )
        
        let hostingController = UIHostingController(rootView: registerView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
}
