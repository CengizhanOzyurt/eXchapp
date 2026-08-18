//
//  CurrencyModel.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 5.08.2026.
//

import Foundation

public struct Currency: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let symbol: String
    public let flagEmoji: String
    public let buyRate: Double
    public let sellRate: Double
    public let changePercent: Double

    public static let mock: [Currency] = [
        Currency(id: "USD", name: "Amerikan Doları", symbol: "$", flagEmoji: "🇺🇸", buyRate: 40.60, sellRate: 40.92, changePercent: 0.12),
        Currency(id: "EUR", name: "Euro", symbol: "€", flagEmoji: "🇪🇺", buyRate: 47.20, sellRate: 47.58, changePercent: -0.04),
        Currency(id: "GBP", name: "İngiliz Sterlini", symbol: "£", flagEmoji: "🇬🇧", buyRate: 54.30, sellRate: 54.72, changePercent: 0.08),
        Currency(id: "CHF", name: "İsviçre Frangı", symbol: "CHF", flagEmoji: "🇨🇭", buyRate: 50.10, sellRate: 50.48, changePercent: 0.03),
        Currency(id: "JPY", name: "Japon Yeni", symbol: "¥", flagEmoji: "🇯🇵", buyRate: 0.27, sellRate: 0.28, changePercent: -0.02),
        Currency(id: "XAU", name: "Gram Altın", symbol: "XAU", flagEmoji: "🏅", buyRate: 4380.00, sellRate: 4415.00, changePercent: 0.18),
        Currency(id: "XAG", name: "Gram Gümüş", symbol: "XAG", flagEmoji: "●", buyRate: 51.50, sellRate: 52.10, changePercent: -0.06)
    ]
}

// MARK: - Currency Response Models
/// Represents the root response structure retrieved from the Exchange API.
/// - Author: Cengizhan Özyurt
/// - Version: 2.0.0
public struct CurrencyResponse: Codable{
    
    public let date : String
    public let rates : [String: Double]?
    
    private enum CodingKeys: String, CodingKey {
        case date
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(String.self, forKey: .date)
        
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var tempRates: [String: Double] = [:]
        
        for key in dynamicContainer.allKeys {
            if key.stringValue != "date" {
                if let rateMap = try? dynamicContainer.decode([String: Double].self, forKey: key){
                    tempRates = rateMap
                    break
                }
            }
        }
        self.rates = tempRates
    }
}

private struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    var intValue: Int?
    init?(intValue: Int) {
        return nil
    }
    
}
