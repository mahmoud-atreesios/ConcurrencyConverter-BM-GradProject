//
//  ViewModel.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 22/08/2023.
//

import Foundation
import RxSwift
import RxRelay

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
        ApiClient.shared().getData(modelDTO: AllCurrenciesModel.self, .getAllCurrencies)
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



