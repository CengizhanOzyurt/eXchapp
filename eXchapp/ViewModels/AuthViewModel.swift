//
//  AuthViewModel.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 6.08.2026.
//

import Foundation
import Combine
import CryptoKit

@MainActor
public final class AuthViewModel: ObservableObject{
    
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    public func register(name: String, surname: String, mail: String, age: Int, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        let passwordHash = String(password.hashValue)
        
        let success = DatabaseManager.shared.registerUser(
            name: name,
            surname: surname,
            mail: mail,
            age: age,
            passwordHash: passwordHash,
            initialBalance: 17500.00
        )
        
        isLoading = false
        
        if success {
            completion(true)
        } else {
            self.errorMessage = "Kayıt işlemi başarısız oldu. Bu e-posta kullanımda olabilir."
            completion(false)
        }
        
    }
    
    public func login(mail: String, password: String, completion: @escaping (Bool) -> Void){
        isLoading = true
        errorMessage = nil
        
        let passwordHash = String(password.hashValue)
        
        if let userTuple = DatabaseManager.shared.loginUser(mail: mail, passwordHash: passwordHash) {
            
            let session = UserSession(
                name: userTuple.name,
                surname: userTuple.surname,
                mail: userTuple.mail,
                balance: userTuple.balance
            )
            AuthManager.shared.logIn(session)
            
            isLoading = false
            completion(true)
        } else {
            isLoading = false
            self.errorMessage = "E-posta veya şifre hatalı."
            completion(false)
        }
    }
    
    public func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

