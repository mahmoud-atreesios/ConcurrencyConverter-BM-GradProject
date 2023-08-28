//
//  AllCurrenciesModel.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 24/08/2023.
//

import Foundation

struct AllCurrenciesModel: Decodable{
    let currencies: [Currency]
}

// MARK: - Currency
struct Currency: Codable {
    let code: String
    let flagURL: String
    let desc: String

    enum CodingKeys: String, CodingKey {
        case code
        case flagURL = "flagUrl"
        case desc
    }
}
