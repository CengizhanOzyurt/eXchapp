//
//  CurrencyModel.swift
//  ExchangeApp
//
//  Created by Cengizhan Özyurt on 5.08.2026.
//

import Foundation

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
