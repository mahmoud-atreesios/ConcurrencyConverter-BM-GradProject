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
        
        setUp()
        setUpIntialValueForDropList()
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
        viewModel.compareCurrency(amount: fromAmount, from: String(fromCurrencyText.dropFirst(1)), toFirstCurrency: String(toFirstCurrencyText.dropFirst(1)), toSecondCurrency: String(toSecondCurrencyText.dropFirst(1)))
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
        
    }
}

extension CompareWithNibFileVC{
    func setUp(){
        let cornerRadius: CGFloat = 20
        let textFieldHeight: CGFloat = 48
        let borderColor = UIColor(red: 0.773, green: 0.773, blue: 0.773, alpha: 1).cgColor
        let borderWidth: CGFloat = 0.5
        let padding: CGFloat = 15
        
        configureTextField(fromAmountTextField, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        configureTextField(firstToAmountTextField, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        
        configureDropDown(fromCurrencyDropList, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        configureDropDown(toFirstCurrencyTypeDropList, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        
        configureDropDown(toSecondCurrencyTypeDropList, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        configureTextField(secondToAmountTextField, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
    }
    
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
    
    func configureDropDown(_ dropDown: DropDown, cornerRadius: CGFloat, height: CGFloat, borderWidth: CGFloat, borderColor: CGColor, padding: CGFloat) {
        dropDown.layer.masksToBounds = true
        dropDown.layer.cornerRadius = cornerRadius
        dropDown.heightAnchor.constraint(equalToConstant: height).isActive = true
        dropDown.layer.borderWidth = borderWidth
        dropDown.layer.borderColor = borderColor
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: height))
        dropDown.leftView = paddingView
        dropDown.leftViewMode = .always
    }
    
    
}

extension CompareWithNibFileVC{
    func setUpIntialValueForDropList(){
        fromCurrencyDropList.text = viewModel.getFlagEmoji(flag: "EGP") + "EGP"
        toFirstCurrencyTypeDropList.text = viewModel.getFlagEmoji(flag: "USD") + "USD"
        toSecondCurrencyTypeDropList.text = viewModel.getFlagEmoji(flag: "USD") + "USD"
    }
}
