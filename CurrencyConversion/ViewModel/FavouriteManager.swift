//
//  testViewModel.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 27/08/2023.
//

import Foundation
import RealmSwift
import RxRelay
import RxSwift

class FavouriteManager {
    private static let sharedInstance = FavouriteManager()

    static func shared() -> FavouriteManager {
        return FavouriteManager.sharedInstance
    }

    private init() {}
    
    var favouriteItems = BehaviorRelay<[FavouriteModel]>(value: [])
    
    func fetchAllCurrencies() {
        favouriteItems.accept(FavouriteCurrenciesManager.shared().getAllFavouritesItems())
    }
}
