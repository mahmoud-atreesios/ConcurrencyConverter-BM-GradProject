//
//  FavouriteModel.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 27/08/2023.
//

import Foundation
import RealmSwift

class FavouriteModel: Object{
    @Persisted(primaryKey: true) var currencyCode: String
    @Persisted var flagURL: String
    
    convenience init(currencyCode: String, flagURL: String) {
        self.init()
        self.currencyCode = currencyCode
        self.flagURL = flagURL
    }
}
