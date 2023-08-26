//
//  CompareWithNibFileVC.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 25/08/2023.
//

import UIKit
import RxSwift
import RxCocoa
import iOSDropDown

class CompareWithNibFileVC: UIViewController {
    
    @IBOutlet weak var fromAmountTextField: UITextField!
    @IBOutlet weak var fromCurrencyDropList: DropDown!
    
    @IBOutlet weak var toSecondCurrencyTypeDropList: DropDown!
    @IBOutlet weak var toFirstCurrencyTypeDropList: DropDown!
    
    @IBOutlet weak var firstToAmountTextField: UITextField!
    @IBOutlet weak var secondToAmountTextField: UITextField!
    
    let viewModel = ConvertViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        fromCurrencyDropList.optionArray = ["A","B","C"]
//        toFirstCurrencyTypeDropList.optionArray = ["A","B","C"]
//        toSecondCurrencyTypeDropList.optionArray = ["A","B","C"]
//
//        fromAmountTextField.text = "100"
//        firstToAmountTextField.text = "200"
//        secondToAmountTextField.text = "200"
        
        fillDropList()
        viewModel.fetchAllCurrencies()
        viewModel.fetchCurrency()
        
        //viewModel.allOfCurrencies
        bindViewToViewModellll()
        
    }
    
    @IBAction func compareButtonPressed(_ sender: UIButton) {
        guard let fromCurrencyText = fromCurrencyDropList.text, !fromCurrencyText.isEmpty,
              let toFirstCurrencyText = toFirstCurrencyTypeDropList.text, !toFirstCurrencyText.isEmpty else {
            return
        }
           guard let toSecondCurrencyText = toSecondCurrencyTypeDropList.text, !toSecondCurrencyText.isEmpty else {
            return
        }
        
        var fromAmount = fromAmountTextField.text ?? "0.0"
        if fromAmount.isEmpty {
            fromAmount = "0.0"
        }
        //String(fromCurrencyText.dropFirst(2))
        viewModel.compareCurrency(amount: fromAmount, from: String(fromCurrencyText.dropFirst(2)), toFirstCurrency: String(toFirstCurrencyText.dropFirst(2)), toSecondCurrency: String(toSecondCurrencyText.dropFirst(2)))
    }
}

extension CompareWithNibFileVC{
    func fillDropList(){
        
        viewModel.allOfCurrencies
            .subscribe { sthKhara in
                self.fromCurrencyDropList.optionArray = self.viewModel.fillDropDown(currencyArray: sthKhara)
                self.toFirstCurrencyTypeDropList.optionArray = self.viewModel.fillDropDown(currencyArray: sthKhara)
                self.toSecondCurrencyTypeDropList.optionArray = self.viewModel.fillDropDown(currencyArray: sthKhara)
            }
            .disposed(by: disposeBag)
            
        
//        viewModel.allOfCurrencies
//            .subscribe { kharaaaa in
//               // print(self.viewModel.fillDropDown(currencyArray: currencyArray))
//                //self.fromCurrencyDropList.optionArray = self.viewModel.fillDropDown(currencyArray: currencyArray)
//                //self.toCurrencyTypeDropList.optionArray = self.viewModel.fillDropDown(currencyArray: currencyArray)
//                self.fromCurrencyDropList.optionArray =
//            }
//            .disposed(by: disposeBag)
    }
}

extension CompareWithNibFileVC{
//    func setUp(){
//        fromAmountTextField.addLeftPadding(padding: 5)
//        toAmountCurrencyTextField.addLeftPadding(padding: 5)
//    }
    
    func bindViewToViewModellll(){
        viewModel.firstComparedCurrency.bind(to: firstToAmountTextField.rx.text).disposed(by: disposeBag)
        viewModel.secoundComparedCurrency.bind(to: secondToAmountTextField.rx.text).disposed(by: disposeBag)

    }
}
