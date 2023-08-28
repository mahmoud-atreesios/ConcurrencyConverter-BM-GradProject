//
//  ConversionModel.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 26/08/2023.
//

import Foundation

struct ConversionModel: Codable {
    let result: Double?
    let timeLastUpdateUTC: String?

    enum CodingKeys: String, CodingKey {
        case result
        case timeLastUpdateUTC = "time_last_update_utc"
    }
}
