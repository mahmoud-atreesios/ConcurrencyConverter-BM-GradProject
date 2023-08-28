//
//  ComparisonModel.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 26/08/2023.
//

import Foundation

struct ComparisonModel: Codable {
    let conversionRates: [ConversionRate]
    let timeLastUpdateUTC: String?

    enum CodingKeys: String, CodingKey {
        case conversionRates = "conversion_rates"
        case timeLastUpdateUTC = "time_last_update_utc"
    }
}

// MARK: - ConversionRate
struct ConversionRate: Codable {
    let currencyCode: String
    let rate, amount: Double
}


