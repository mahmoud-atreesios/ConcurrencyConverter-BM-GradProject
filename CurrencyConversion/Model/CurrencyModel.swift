//
//  Model.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 22/08/2023.
//

import Foundation
import RxRelay

struct CurrencyModel: Codable {
    var localDic = BehaviorRelay<[String: Double]>(value: ["USD": 0.0])

    let result: String
    let documentation, termsOfUse: String
    let timeLastUpdateUnix: Int
    let timeLastUpdateUTC: String
    let timeNextUpdateUnix: Int
    let timeNextUpdateUTC, baseCode: String
    let conversionRates: [String: Double]

    enum CodingKeys: String, CodingKey {
        case result, documentation
        case termsOfUse = "terms_of_use"
        case timeLastUpdateUnix = "time_last_update_unix"
        case timeLastUpdateUTC = "time_last_update_utc"
        case timeNextUpdateUnix = "time_next_update_unix"
        case timeNextUpdateUTC = "time_next_update_utc"
        case baseCode = "base_code"
        case conversionRates = "conversion_rates"
    }
}

extension CurrencyModel {
    func convert(amount: Double, from: String, to: String) -> Double {
        guard let fromRatioRelativeToBase = conversionRates[from] else {
            return 0
        }

        guard let toRatioRelativeToBase = conversionRates[to] else {
            return 0
        }

        let valueRelativeToBase = amount / fromRatioRelativeToBase // IN USD

        let result = valueRelativeToBase * toRatioRelativeToBase

        return Double(String(format: "%.2f", result)) ?? 0.0
    }

    func convertAllCurrencies(amount: Double, from: String) -> [String: Double] {
        var localDic: [String: Double] = [:]
        for currencyy in conversionRates {
            localDic[currencyy.key] = convert(amount: amount, from: from, to: currencyy.key)
        }
        return localDic
    }
}
