//
//  RealmCurrencyModel.swift
//  CurrencyConversion
//
//  Created by Hend on 26/08/2023.
//

import Foundation
import RealmSwift

class RealmCurrency: Object {
    @Persisted var code = ""
    @Persisted var flagURL = ""
    @Persisted var desc = ""
}
