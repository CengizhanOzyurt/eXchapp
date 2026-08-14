//
//  HomeViewController.swift
//  eXchapp
//
//  Created by Cengizhan Özyurt on 13.08.2026.
//

import UIKit
import SwiftUI

public class HomeViewController: UIViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupHostingController()
    }
    
    private func setupHostingController() {
        
        let homeView = HomeView(
            onLoginPromptRequested: { [weak self] in
                self?.navigateToLogin()
            },
            onRegisterPromptRequested: { [weak self] in
                self?.navigateToRegister()
            }
        )
        
        let hostingController = UIHostingController(rootView: homeView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
    private func navigateToLogin() {
            let loginView = LoginView(onLoginSuccess: { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            }, onRegisterTapped: { [weak self] in
                self?.navigateToRegister()
            })
    
            let hostingVC = UIHostingController(rootView: loginView)
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.pushViewController(hostingVC, animated: true)
        }
    private func navigateToRegister() {
        let registerView = RegisterView(onRegisterSuccess: { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        
        let hostingVC = UIHostingController(rootView: registerView)
        navigationController?.pushViewController(hostingVC, animated: true)
    }
}
