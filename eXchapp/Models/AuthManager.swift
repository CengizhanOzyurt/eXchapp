//
//  AuthManager.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 6.08.2026.
//

import Foundation
import Combine

public struct UserSession {
    public let name: String
    public let surname: String
    public let mail: String
    public let balance: Double
    
    public init(name: String, surname: String, mail: String, balance: Double) {
        self.name = name
        self.surname = surname
        self.mail = mail
        self.balance = balance
    }
}

@MainActor
public final class AuthManager: ObservableObject {
    public static let shared = AuthManager()
    
    @Published public var isLoggedIn: Bool = false
    @Published public var currentUser: UserSession? = nil
    
    private init() {}
    
    public func logIn(_ user: UserSession) {
        self.currentUser = user
        self.isLoggedIn = true
    }
    public func logOut() {
        self.currentUser = nil
        self.isLoggedIn = false
    }
}
