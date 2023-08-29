//
//  FavouriteCurrenciesManager.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 27/08/2023.
//

import Foundation
import RealmSwift

class FavouriteCurrenciesManager {
    private static let sharedInstance = FavouriteCurrenciesManager()

    static func shared() -> FavouriteCurrenciesManager {
        return FavouriteCurrenciesManager.sharedInstance
    }

    private init() {}

    let realm = try! Realm()

    func addRealmCurrency(_ realmCurrency: FavouriteModel) {
        try! realm.write {
            if let existingItem = realm.object(ofType: FavouriteModel.self, forPrimaryKey: realmCurrency.currencyCode) {
                if !existingItem.isInvalidated {
                    realm.delete(existingItem)
                }
            }

            let newItem = FavouriteModel(currencyCode: realmCurrency.currencyCode, flagURL: realmCurrency.flagURL)

            realm.add(newItem, update: .modified)
        }
        // Update favouriteItems
        // viewModel.favouriteItems.accept(getAllFavouritesItems())
    }

    func deleteRealmCurrency(_ realmCurrency: FavouriteModel) {
        if let objectToDelete = realm.object(ofType: FavouriteModel.self, forPrimaryKey: realmCurrency.currencyCode) {
            try! realm.write {
                realm.delete(objectToDelete)
            }
        }
        // Update favouriteItems
        // viewModel.favouriteItems.accept(getAllFavouritesItems())  , viewModel: ConvertViewModel
    }

    func isItemFavorited(_ realmCurrency: FavouriteModel) -> Bool {
        let realm = try! Realm()

        return realm.object(ofType: FavouriteModel.self, forPrimaryKey: realmCurrency.currencyCode) != nil
    }

    func returnDataBaseURL() -> String {
        if let realmURL = Realm.Configuration.defaultConfiguration.fileURL {
            return "Realm database URL: \(realmURL)"
        }
        return "Coudn't Found the DataBase"
    }

    func getAllFavouritesItems() -> [FavouriteModel] {
        let favouriteItems = realm.objects(FavouriteModel.self)
        return Array(favouriteItems)
    }
}
