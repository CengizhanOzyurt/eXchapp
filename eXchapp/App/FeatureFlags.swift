//
//  AppConfig.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 5.08.2026.
//

import Foundation
import Combine

// MARK: - App Configuration Manager
/// A centralized configuration manager responsible for handling application-wide feature flags and runtime settings.
/// - Author : Cengizhan Özyurt
/// - Version: 1.0.0
public enum FeatureFlags {
    
    public static let themeChangedNotification = NSNotification.Name("ThemeChangedNotification")
    
    public static var liquidGlassEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "liquidGlassEnabled") }
        set {
            UserDefaults.standard.set(newValue, forKey: "liquidGlassEnabled")
            NotificationCenter.default.post(name: themeChangedNotification, object: nil)
        }
    }
}
