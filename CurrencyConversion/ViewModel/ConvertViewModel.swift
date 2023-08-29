//
//  ViewModel.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 22/08/2023.
//

import Foundation
import RealmSwift
import RxRelay
import RxSwift

class ConvertViewModel {
    private let disposeBag = DisposeBag()
    
    var exchangeCurrency: CurrencyModel?
    var allCurrencies: AllCurrenciesModel?
    var conversionModel: ConversionModel?
    var compareModel: ComparisonModel?
    
    var currencyRates = BehaviorRelay<[String: Double]>(value: ["USD": 0.0])
    var allOfCurrencies = PublishRelay<[Currency]>.init()
    var favouriteItems = BehaviorRelay<[FavouriteModel]>(value: FavouriteCurrenciesManager.shared().getAllFavouritesItems())
    
    var errorSubject = PublishSubject<Error>.init()
    
    var fromCurrencyRelay = BehaviorRelay<String>(value: "")
    var fromAmountRelay = BehaviorRelay<Double>(value: 1.0)
    
    var conversion = PublishRelay<String>()
    
    var firstComparedCurrency = PublishRelay<String>()
    var secoundComparedCurrency = PublishRelay<String>()
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    
    func fetchCurrency() {
        isLoading.accept(true)
        let favoriteFromCurrency = UserDefaults.standard.string(forKey: "favoriteFromCurrency") ?? "USD"
        ApiClient.shared().getData(modelDTO: CurrencyModel.self, .getExchangeRate(base: favoriteFromCurrency))
            .subscribe { currency in
                AppConfigs.dict[favoriteFromCurrency] = currency.conversionRates
                self.exchangeCurrency = currency
                self.currencyRates.accept(currency.conversionRates)
                DispatchQueue.main.async {
                    FavouriteManager.shared().fetchAllCurrencies()
                }
                self.isLoading.accept(false)
            } onError: { error in
                self.errorSubject.onNext(error)
                self.isLoading.accept(false)
            }
            .disposed(by: disposeBag)
    }
    
    func fetchAllCurrencies() {
        isLoading.accept(true)
        ApiClient.shared().getData(modelDTO: AllCurrenciesModel.self, .getAllCurrenciesData)
            .subscribe { listOfAllCurrencies in
                self.allCurrencies = listOfAllCurrencies
                self.allOfCurrencies.accept(listOfAllCurrencies.currencies)
                // self.currencyRates.accept(currency.conversionRates)
                self.isLoading.accept(false)
            } onError: { error in
                self.errorSubject.onNext(error)
                self.isLoading.accept(false)
            }
            .disposed(by: disposeBag)
    }
    
    func convertCurrency(amount: String, from: String, to: String) {
        isLoading.accept(true)
        ApiClient.shared().getData(modelDTO: ConversionModel.self, .convertCurrency(from: from, to: to, amount: amount))
            .subscribe(onNext: { conversion in
                self.conversion.accept(self.formattedAndTrimmedValue(conversion.result ?? 0))
                self.isLoading.accept(false)
            }, onError: { error in
                self.errorSubject.onNext(error)
                self.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    func compareCurrency(amount: String, from: String, toFirstCurrency: String, toSecondCurrency: String) {
        isLoading.accept(true)
        ApiClient.shared().getData(modelDTO: ComparisonModel.self, .compareCurrencies(from: from, amount: amount, toFirst: toFirstCurrency, toSecond: toSecondCurrency))
            .subscribe(onNext: { comparison in
                self.firstComparedCurrency.accept(self.formattedAndTrimmedValue(comparison.conversionRates[0].amount))
                self.secoundComparedCurrency.accept(self.formattedAndTrimmedValue(comparison.conversionRates[1].amount))
                self.isLoading.accept(false)
            }, onError: { error in
                self.errorSubject.onNext(error)
                self.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }

}

// MARK: Helping Function

extension ConvertViewModel {
    func fillDropDown(currencyArray: [Currency]) -> [String] {
        var arr = [String]()
        if let allCurrencies = allCurrencies {
            for flag in allCurrencies.currencies {
                arr.append(" " + getFlagEmoji(flag: flag.code) + flag.code)
            }
        }
        return arr
    }

    func getFlagEmoji(flag: String) -> String {
        let code = flag.dropLast()
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in code.unicodeScalars {
            emoji.append(String(UnicodeScalar(base + scalar.value)!))
        }
        return emoji
    }
    
     func formattedAndTrimmedValue(_ value: Double) -> String {
        let formattedResult = String(format: "%.4f", value)
        
        if formattedResult.hasPrefix("0.") {
            return "0" + formattedResult.dropFirst(1)
        }
        
        var trimmedResult = formattedResult.trimmingCharacters(in: .init(charactersIn: "0"))
        if trimmedResult.last == "." {
            trimmedResult.removeLast()
        }
        return trimmedResult
    }
}

