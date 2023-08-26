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
    var currencyRates = BehaviorRelay<[String:Double]>(value: ["USD":0.0])
    var allOfCurrencies = PublishRelay<[Currency]>.init()
    
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
        let realm = try! Realm()
        var realmCurrencyArray: [RealmCurrency] = []
        ApiClient.shared().getData(modelDTO: AllCurrenciesModel.self, .getAllCurrencies)
            .subscribe { listOfAllCurrencies in
                
                realmCurrencyArray = listOfAllCurrencies.currencies.map{ Currency in
                    let realmCurrency = RealmCurrency()
                    realmCurrency.code = Currency.code
                    realmCurrency.desc = Currency.desc
                    realmCurrency.flagURL = Currency.flagURL
                    return realmCurrency
                }
                
                self.printRealmComponents()
                
                self.allCurrencies = listOfAllCurrencies
                self.allOfCurrencies.accept(listOfAllCurrencies.currencies)
                for currency in realmCurrencyArray {
                    self.addRealmCurrency(currency)
                }
//                DispatchQueue.main.async {
//                    try! realm.write {
//                        realm.add(realmCurrencyArray)
//                        
//                    }
//                    
//                }
                
                                                                    

                //self.currencyRates.accept(currency.conversionRates)
            } onError: { error in
                print(error)
                self.errorSubject.onNext(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    

    
    func addRealmCurrency(_ realmCurrency: RealmCurrency) {
        let realm = try! Realm()

        do {
            try realm.write {
                realm.add(realmCurrency)
                print("Added currency: \(realmCurrency)")
            }
        } catch {
            print("Error adding currency: \(error)")
        }
    }

    func deleteRealmCurrency(_ realmCurrency: RealmCurrency) {
        let realm = try! Realm()

        if let existingCurrency = realm.objects(RealmCurrency.self).filter("desc == %@ AND code == %@ AND flagURL == %@", realmCurrency.desc, realmCurrency.code, realmCurrency.flagURL).first {
            do {
                try realm.write {
                    realm.delete(existingCurrency)
                    print("Deleted currency: \(existingCurrency)")
                }
            } catch {
                print("Error deleting currency: \(error)")
            }
        } else {
            print("Currency not found in the database.")
        }
    }
    func printRealmComponents() {
        let realm = try! Realm()
        let realmCurrencies = realm.objects(RealmCurrency.self)
        
        print("Realm Currency Components:")
        for currency in realmCurrencies {
            print("Code: \(currency.code), Desc: \(currency.desc), Flag URL: \(currency.flagURL)")
        }
    }






    
    
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


