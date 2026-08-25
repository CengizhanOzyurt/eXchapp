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
    private var classicTabBar: UIView?
    private var classicTabButtons: [UIButton] = []

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
        configureClassicTabBar()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChange),
            name: FeatureFlags.themeChangedNotification,
            object: nil
        )
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        removeClassicModeSelectionEffectsIfNeeded()
        updateClassicTabBarVisibility()
    }
    
    // MARK: - Anlık Tema Değişimi (Gecikmesiz)
    @objc private func handleThemeChange() {
        UIView.performWithoutAnimation {
            self.configureAppearance()
            self.tabBar.layoutIfNeeded()
            self.updateClassicTabBarVisibility()
            self.updateClassicSelection()
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

    private func configureClassicTabBar() {
        guard classicTabBar == nil else { return }

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemBackground
        container.layer.borderColor = UIColor.separator.withAlphaComponent(0.45).cgColor
        container.layer.borderWidth = 0.5
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.14
        container.layer.shadowRadius = 12
        container.layer.shadowOffset = CGSize(width: 0, height: -4)

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 4
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 6, left: 6, bottom: 2, right: 6)

        viewControllers?.enumerated().forEach { index, viewController in
            let button = makeClassicTabButton(
                title: viewController.tabBarItem.title ?? "",
                image: viewController.tabBarItem.image,
                index: index
            )
            classicTabButtons.append(button)
            stackView.addArrangedSubview(button)
        }

        container.addSubview(stackView)
        view.addSubview(container)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            container.topAnchor.constraint(equalTo: tabBar.topAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        classicTabBar = container
        updateClassicSelection()
        updateClassicTabBarVisibility()
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
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = .systemBackground
            appearance.shadowColor = UIColor.separator
            appearance.selectionIndicatorTintColor = .clear
            appearance.selectionIndicatorImage = Self.clearSelectionIndicatorImage()
            
            configureItemAppearance(
                appearance,
                selectedColor: AppTheme.uiAccent,
                normalColor: .secondaryLabel
            )
            
            tabBar.isTranslucent = false
            tabBar.isOpaque = true
            tabBar.backgroundColor = .systemBackground
            tabBar.barTintColor = .systemBackground
            tabBar.tintColor = AppTheme.uiAccent
            tabBar.unselectedItemTintColor = .secondaryLabel
            tabBar.backgroundImage = nil
            tabBar.shadowImage = nil
            tabBar.selectionIndicatorImage = Self.clearSelectionIndicatorImage()
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
        updateClassicTabBarVisibility()
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

    private func removeClassicModeSelectionEffectsIfNeeded() {
        let shouldHideSelectionEffects = !FeatureFlags.liquidGlassEnabled

        tabBar.subviews.forEach { subview in
            let className = String(describing: type(of: subview))
            if className.contains("Selection") ||
                className.contains("Indicator") ||
                className.contains("Effect") {
                subview.isHidden = shouldHideSelectionEffects
                subview.alpha = shouldHideSelectionEffects ? 0 : 1
            }
        }
    }

    private func shouldUseClassicTabBarFallback() -> Bool {
        return !FeatureFlags.liquidGlassEnabled
    }

    private func updateClassicTabBarVisibility() {
        let useFallback = shouldUseClassicTabBarFallback()

        // Sistem tab bar görünürlük ve etkileşim ayarı
        tabBar.alpha = useFallback ? 0 : 1
        tabBar.isUserInteractionEnabled = !useFallback

        // Özel klasik bar gizleme ve katman yönetimi
        classicTabBar?.isHidden = !useFallback
        classicTabBar?.isUserInteractionEnabled = useFallback
        
        if useFallback {
            if let classicBar = classicTabBar {
                view.bringSubviewToFront(classicBar)
            }
            updateClassicSelection()
        } else {
            if let classicBar = classicTabBar {
                view.sendSubviewToBack(classicBar)
            }
        }
    }

    private func makeClassicTabButton(title: String, image: UIImage?, index: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = index
        button.tintColor = .secondaryLabel
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(handleClassicTabSelection(_:)), for: .touchUpInside)

        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.title = title
            configuration.image = image
            configuration.imagePlacement = .top
            configuration.imagePadding = 4
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 3, trailing: 0)
            configuration.baseForegroundColor = .secondaryLabel
            configuration.background.backgroundColor = .clear
            button.configuration = configuration
        } else {
            button.setTitle(title, for: .normal)
            button.setImage(image, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 10, weight: .regular)
        }

        return button
    }

    @objc private func handleClassicTabSelection(_ sender: UIButton) {
        UIView.performWithoutAnimation {
            selectedIndex = sender.tag
            updateClassicSelection()
        }
    }

    private func updateClassicSelection() {
        classicTabButtons.enumerated().forEach { index, button in
            let isSelected = index == selectedIndex
            let color = isSelected ? AppTheme.uiAccent : UIColor.secondaryLabel
            button.tintColor = color
            button.setTitleColor(color, for: .normal)
            if #available(iOS 15.0, *) {
                var configuration = button.configuration
                configuration?.baseForegroundColor = color
                configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var outgoing = incoming
                    outgoing.font = .systemFont(ofSize: 10.5, weight: isSelected ? .semibold : .bold)
                    return outgoing
                }
                button.configuration = configuration
            } else {
                button.titleLabel?.font = .systemFont(ofSize: 10.5, weight: isSelected ? .semibold : .bold)
            }
            button.backgroundColor = .clear
            button.layer.removeAllAnimations()
        }
    }

    private static func clearSelectionIndicatorImage() -> UIImage {
        let size = CGSize(width: 1, height: 1)
        return UIGraphicsImageRenderer(size: size).image { context in
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
