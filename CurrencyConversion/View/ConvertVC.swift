//
//  ViewController.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 22/08/2023.
//

import UIKit
import RxSwift
import RxCocoa

class ConvertVC: UIViewController {
    
    @IBOutlet weak var fromAmountTextField: UITextField!
    @IBOutlet weak var fromCurrencyTextField: UITextField!
    
    @IBOutlet weak var toAmountTextField: UITextField!
    @IBOutlet weak var toCurrencyTextField: UITextField!
    
    @IBOutlet weak var favoritesCurrenciesTableView: UITableView!
    
    let viewModel = ConvertViewModel()
    let disposeBag = DisposeBag()
    let convertButtonPressed = PublishSubject<Void>()
    
    let usdEmoji = currencyCodeToEmoji("US") // 🇺🇸
    let egpEmoji = currencyCodeToEmoji("EG") // 🇪🇬
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fromCurrencyTextField.font = UIFont.systemFont(ofSize: 17)
        toCurrencyTextField.font = UIFont.systemFont(ofSize: 17)

//        fromCurrencyTextField.text = "\(usdEmoji) USD"
//        toCurrencyTextField.text = "\(egpEmoji) EGP"
        print(usdEmoji)
        
        viewModel.fetchCurrency()
        bindViewModel()
        viewModel.fromUSDtoEGP()
        bindViewModelToViews()
        bindViewsToViewModel()
    }

    @IBAction func convertButtonPressed(_ sender: UIButton) {
        viewModel.convertButtonPressedRelay.accept(())
    }
    
}

extension ConvertVC{
    
    func bindViewModelToViews(){
        viewModel.fromCurrencyOutPutRelay.bind(to: fromAmountTextField.rx.text).disposed(by: disposeBag)
        viewModel.toCurrencyOutPutRelay.bind(to: toAmountTextField.rx.text).disposed(by: disposeBag)
        
        viewModel.fromCurrencyRelay.bind(to: fromCurrencyTextField.rx.text).disposed(by: disposeBag)
        viewModel.toCurrencyRelay.bind(to: toCurrencyTextField.rx.text).disposed(by: disposeBag)
    }
    
    func bindViewsToViewModel(){
        
        fromAmountTextField.rx
            .text
            .orEmpty
            .map { $0.isEmpty ? "0.0" : $0 }
            .compactMap(Double.init)
            .bind(to: viewModel.fromAmountRelay)
            .disposed(by: disposeBag)


        
        toAmountTextField.rx
            .text
            .orEmpty
            .map { $0.isEmpty ? "0.0" : $0 }
            .compactMap(Double.init)
            .bind(to: viewModel.toAmountRelay)
            .disposed(by: disposeBag)
        
        fromCurrencyTextField.rx
            .text
            .orEmpty
            .bind(to: viewModel.fromCurrencyRelay)
            .disposed(by: disposeBag)

        toCurrencyTextField.rx
            .text
            .orEmpty
            .bind(to: viewModel.toCurrencyRelay)
            .disposed(by: disposeBag)
        
    }
    
    
    func bindViewModel(){
        viewModel.currencyRates
            .bind(to: favoritesCurrenciesTableView.rx.items(cellIdentifier: "currencyCell", cellType: ConversionRateTableViewCell.self)){
                (row,exchangeRate,cell) in
                cell.keyCurrency.text = String(exchangeRate.key)
                cell.valueCurrency.text = String(exchangeRate.value)
            }
            .disposed(by: disposeBag)
    }
}

extension ConvertVC{
    static func currencyCodeToEmoji(_ code: String) -> String {
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in code.unicodeScalars {
            emoji.append(String(UnicodeScalar(base + scalar.value)!))
        }
        return emoji
    }
}
