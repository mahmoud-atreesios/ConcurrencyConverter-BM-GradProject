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
        

        let cornerRadius: CGFloat = 20
            let textFieldHeight: CGFloat = 48
            let borderColor = UIColor(red: 0.773, green: 0.773, blue: 0.773, alpha: 1).cgColor
            let borderWidth: CGFloat = 0.5
            let padding: CGFloat = 15
        
        
        if let customView = Bundle.main.loadNibNamed("Compare", owner: self, options: nil)?.first as? Compare {
            self.view = customView
            
            print("I am in the CompareVC")
            
        }

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
    
    
    func configureTextField(_ textField: UITextField, cornerRadius: CGFloat, height: CGFloat, borderWidth: CGFloat, borderColor: CGColor, padding: CGFloat) {
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = cornerRadius
        textField.heightAnchor.constraint(equalToConstant: height).isActive = true
        textField.layer.borderWidth = borderWidth
        textField.layer.borderColor = borderColor
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }

//    func configureDropDown(_ dropDown: DropDown, cornerRadius: CGFloat, height: CGFloat, borderWidth: CGFloat, borderColor: CGColor, padding: CGFloat) {
//        dropDown.layer.masksToBounds = true
//        dropDown.layer.cornerRadius = cornerRadius
//        dropDown.heightAnchor.constraint(equalToConstant: height).isActive = true
//        dropDown.layer.borderWidth = borderWidth
//        dropDown.layer.borderColor = borderColor
//        
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: height))
//        dropDown.leftView = paddingView
//        dropDown.leftViewMode = .always
//    }
    
    
}
