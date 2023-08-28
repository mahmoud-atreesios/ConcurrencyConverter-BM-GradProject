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
import Reachability

class CompareWithNibFileVC: UIViewController {
    
    @IBOutlet weak var fromAmountTextField: UITextField!
    @IBOutlet weak var fromCurrencyDropList: DropDown!
    
    @IBOutlet weak var toSecondCurrencyTypeDropList: DropDown!
    @IBOutlet weak var toFirstCurrencyTypeDropList: DropDown!
    
    @IBOutlet weak var firstToAmountTextField: UITextField!
    @IBOutlet weak var secondToAmountTextField: UITextField!
    
    let viewModel = ConvertViewModel()
    let disposeBag = DisposeBag()
    
    var loader: UIActivityIndicatorView!
    let reachability = try! Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setUp()
        setUpLoader()
        setUpIntialValueForDropList()
        fillDropList()
        viewModel.fetchAllCurrencies()
        viewModel.fetchCurrency()
        resetToAmountTextField()
        
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
        if reachability.connection == .unavailable {
            // If the network is unavailable, start the loader
            DispatchQueue.main.async {
                self.loader.startAnimating()
            }
            
        } else {
            // If the network is available, stop the loader and call convertCurrency
            loader.stopAnimating()
            viewModel.compareCurrency(amount: fromAmount, from: String(fromCurrencyText.dropFirst(2)), toFirstCurrency: String(toFirstCurrencyText.dropFirst(2)), toSecondCurrency: String(toSecondCurrencyText.dropFirst(2)))
            
        }
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
    func setUpLoader(){
        loader = UIActivityIndicatorView(style: .large)
        loader.center = CGPoint(x: 180, y: 200)
        view.addSubview(loader)
        
        viewModel.isLoading
            .asObservable()
            .subscribe(onNext: { [weak self] isLoading in
                DispatchQueue.main.async {
                    if isLoading {
                        self?.loader.startAnimating()
                    } else {
                        self?.loader.stopAnimating()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setUp(){
        let cornerRadius: CGFloat = 20
        let textFieldHeight: CGFloat = 48
        let borderColor = UIColor(red: 0.773, green: 0.773, blue: 0.773, alpha: 1).cgColor
        let borderWidth: CGFloat = 0.5
        let padding: CGFloat = 15
        
        firstToAmountTextField.isUserInteractionEnabled = false
        secondToAmountTextField.isUserInteractionEnabled = false

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
    
}

extension CompareWithNibFileVC{
    func setUpIntialValueForDropList(){
        fromCurrencyDropList.text = " " + viewModel.getFlagEmoji(flag: "EGP") + "EGP"
        toFirstCurrencyTypeDropList.text = " " + viewModel.getFlagEmoji(flag: "USD") + "USD"
        toSecondCurrencyTypeDropList.text = " " + viewModel.getFlagEmoji(flag: "USD") + "USD"
    }
    func resetToAmountTextField(){
        fromAmountTextField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] _ in
                self?.firstToAmountTextField.text = ""
                self?.secondToAmountTextField.text = ""
            })
            .disposed(by: disposeBag)
    }
}
