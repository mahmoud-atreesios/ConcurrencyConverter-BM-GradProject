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

class testViewModel {
    private static let sharedInstance = testViewModel()

    static func shared() -> testViewModel {
        return testViewModel.sharedInstance
    }

    private init() {}
    
    var favouriteItems = BehaviorRelay<[FavouriteModel]>(value: [])
    
    func fetchAllCurrencies() {
        favouriteItems.accept(FavouriteCurrenciesManager.shared().getAllFavouritesItems())
    }
}
