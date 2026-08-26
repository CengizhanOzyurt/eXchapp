//
//  NetworkManager.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 6.08.2026.
//

import Foundation

// MARK: - Network Error Types
/// Defines custom networking errors for robust error handling.
public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingFailed
    case serverError(statusCode: Int)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The requested URL is invalid."
        case .noData:
            return "No data was received from the server."
        case .decodingFailed:
            return "Failed to parse the response data."
        case .serverError(let code):
            return "Server responded with status code: \(code)."
        
        }
    }
}


// MARK: - Network Manager Service
/// Manages asynchronous network requests to fetch exchange rates from the API.
/// - Author: Cengizhan Özyurt
/// - Version: 1.0.0
public final class NetworkManager {
    
    public static let shared = NetworkManager()
    private let baseURL = "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/try.json"
    private init() {}
    
    public func fetchLatestRates() async throws -> CurrencyResponse {
        guard let url = URL(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        do {
            let decodedResponse = try JSONDecoder().decode(CurrencyResponse.self, from: data)
            return decodedResponse
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
    
