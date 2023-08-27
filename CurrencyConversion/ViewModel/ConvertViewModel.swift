//
//  ViewModel.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 22/08/2023.
//

import Foundation
import RxSwift
import RxRelay
import RealmSwift

class ConvertViewModel{
    
    private let disposeBag = DisposeBag()
    
    var exchangeCurrency: CurrencyModel?
    var allCurrencies: AllCurrenciesModel?
    var conversionModel: ConversionModel?
    var compareModel: ComparisonModel?
    
    var currencyRates = BehaviorRelay<[String:Double]>(value: ["USD":0.0])
    var allOfCurrencies = PublishRelay<[Currency]>.init()
    var favouriteItems = BehaviorRelay<[FavouriteModel]>(value: FavouriteCurrenciesManager.shared().getAllFavouritesItems())
    
    var errorSubject = PublishSubject<String>.init()
    
    // Input
    var fromCurrencyRelay = BehaviorRelay<String>(value: "")
    var toCurrencyRelay = BehaviorRelay<String>(value: "")
    var fromAmountRelay = BehaviorRelay<Double>(value: 1.0)
    var toAmountRelay = BehaviorRelay<Double>(value: 0.0)
    
    // Output
    var toCurrencyOutPutRelay = PublishRelay<String>.init()
    var fromCurrencyOutPutRelay = PublishRelay<String>.init()
    var convertButtonPressedRelay = PublishRelay<Void>()
    
    var conversion = PublishRelay<String>()
    var firstComparedCurrency = PublishRelay<String>()
    var secoundComparedCurrency = PublishRelay<String>()
    
    // var placeholderOutputRelay = PublishRelay<String>.init()
    
    
    func fetchCurrency(){
        ApiClient.shared().getData(modelDTO: CurrencyModel.self, .getExchangeRate)
            .subscribe { currency in
                self.exchangeCurrency = currency
                self.currencyRates.accept(currency.conversionRates)
            } onError: { error in
                print(error)
            }
            .disposed(by: disposeBag)
    }
    
    func fetchAllCurrencies(){
        ApiClient.shared().getData(modelDTO: AllCurrenciesModel.self, .getAllCurrenciesData)
            .subscribe { listOfAllCurrencies in
                self.allCurrencies = listOfAllCurrencies
                self.allOfCurrencies.accept(listOfAllCurrencies.currencies)
                //self.currencyRates.accept(currency.conversionRates)
            } onError: { error in
                print(error)
                self.errorSubject.onNext(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
//    func convertCurrency(amount: String, from: String, to: String) -> Observable<String> {
//        return Observable.create { observer in
//            ApiClient.shared().getData(modelDTO: ConversionModel.self, .convertCurrency(from: from, to: to, amount: amount))
//                .subscribe(onNext: { conversion in
//                    let result = String(format: "%.2f", conversion.result ?? 1)
//                    observer.onNext(result)
//                }, onError: { error in
//                    print(error)
//                    self.errorSubject.onNext(error.localizedDescription)
//                })
//                .disposed(by: self.disposeBag)
//        }
//    }

    
    func convertCurrency(amount: String, from: String, to: String){
        ApiClient.shared().getData(modelDTO: ConversionModel.self, .convertCurrency(from: from, to: to, amount: amount))
            .subscribe(onNext: { conversion in
                self.conversion.accept(String(format: "%.2f", conversion.result ?? 1))
                
            }, onError: { error in
                print(error)
                self.errorSubject.onNext(error.localizedDescription)
                
            })
            .disposed(by: disposeBag)
    }
    
    func compareCurrency(amount: String, from: String, toFirstCurrency: String, toSecondCurrency: String){
        ApiClient.shared().getData(modelDTO: ComparisonModel.self, .compareCurrencies(from: from, amount: amount, toFirst: toFirstCurrency, toSecond: toSecondCurrency))
            .subscribe(onNext: { comparison in
                //self.comparison.accept(comparison.conversionRates)
                self.firstComparedCurrency.accept(String(format: "%.2f", comparison.conversionRates[0].amount))
                self.secoundComparedCurrency.accept(String(format: "%.2f", comparison.conversionRates[1].amount))
            }, onError: { error in
                print(error)
                self.errorSubject.onNext(error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        func fromUSDtoEGP(){
            convertButtonPressedRelay.subscribe(onNext: { [weak self] _ in
                guard let self = self, let model = self.exchangeCurrency else { return }
                let amount = self.fromAmountRelay.value
                let from = self.fromCurrencyRelay.value
                let to = self.toCurrencyRelay.value
                let convertedAmount = model.convert(amount: amount, from: from, to: to)
                self.toCurrencyOutPutRelay.accept(String.init(convertedAmount))
                let convertedCurrencies = model.convertAllCurrencies(amount: amount, from: from)
                self.currencyRates.accept(convertedCurrencies)
            }).disposed(by: disposeBag)
        }
        
    }
}

//MARK: Helping Function
extension ConvertViewModel{
    func fillDropDown(currencyArray: [Currency]) -> [String]{
        var arr = [String]()
        if let allCurrencies = allCurrencies{
            for flag in allCurrencies.currencies{
                arr.append(" " + getFlagEmoji(flag: flag.code) + flag.code)
            }
        }
        return arr
    }
    func getFlagEmoji(flag: String) -> String{
        let code = flag.dropLast()
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in code.unicodeScalars {
            emoji.append(String(UnicodeScalar(base + scalar.value)!))
        }
        return emoji
    }
}


