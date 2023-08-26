//
//  ViewController.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 25/08/2023.
//

import UIKit
import RxSwift
import RxCocoa
import iOSDropDown

class ConvertWithNibFileVC: UIViewController {
    
    @IBOutlet weak var fromAmountCurrencyTextField: UITextField!
    @IBOutlet weak var fromCurrencyTypeDropList: DropDown!
    
    @IBOutlet weak var toAmountCurrencyTextField: UITextField!
    @IBOutlet weak var toCurrencyTypeDropList: DropDown!
    
    
    @IBOutlet weak var selectedFavouriteCurrenciesTableView: UITableView!
    
    let viewModel = ConvertViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
//        fromCurrencyTypeDropList.text = "USD"
//        toCurrencyTypeDropList.text = "EGP"
        

        bindViewToViewModellll()
        setUp()

        
        let cornerRadius: CGFloat = 20
            let textFieldHeight: CGFloat = 48
            let borderColor = UIColor(red: 0.773, green: 0.773, blue: 0.773, alpha: 1).cgColor
            let borderWidth: CGFloat = 0.5
            let padding: CGFloat = 15
            
            configureTextField(fromAmountCurrencyTextField, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
            configureTextField(toAmountCurrencyTextField, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
            
            configureDropDown(fromCurrencyTypeDropList, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
            configureDropDown(toCurrencyTypeDropList, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        
        fromCurrencyTypeDropList.text = "USD"
        toCurrencyTypeDropList.text = "EGP"
        

        fillDropList()
        viewModel.fetchAllCurrencies()
        viewModel.fetchCurrency()
        bindTableViewToViewModel()
        //bindViewsToViewModel()
        //bindViewModelToViews()
        //viewModel.fromUSDtoEGP()
        selectedFavouriteCurrenciesTableView.register(UINib(nibName: "CurrencyCell", bundle: nil), forCellReuseIdentifier: "currencyCell")
    }
    
    @IBAction func convertButtonPressed(_ sender: UIButton) {
        //viewModel.convertButtonPressedRelay.accept(())
        guard let fromCurrencyText = fromCurrencyTypeDropList.text, !fromCurrencyText.isEmpty,
                      let toCurrencyText = toCurrencyTypeDropList.text, !toCurrencyText.isEmpty else {
                    return
                }

                var fromAmount = fromAmountCurrencyTextField.text ?? "0.0"
                if fromAmount.isEmpty {
                    fromAmount = "0.0"
                }

                viewModel.convertCurrency(amount: fromAmount, from: String(fromCurrencyText.dropFirst(2)), to: String(toCurrencyText.dropFirst(2)))
        
    }
    
    @IBAction func addToFavouritesButtonPressed(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let profileScreen = sb.instantiateViewController(withIdentifier: "AddToFavoritesVC") as! AddToFavoritesVC
        self.present(profileScreen, animated: true)
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

extension ConvertWithNibFileVC{
    func bindTableViewToViewModel() {
        print("ana gwa l function")
        
        viewModel.currencyRates
            .bind(to: selectedFavouriteCurrenciesTableView.rx.items(cellIdentifier: "currencyCell", cellType: CurrencyCell.self)){
                (row,exchangeRate,cell) in
                cell.baseLabel.text = "Currency"
                cell.currencyLabel.text = String(exchangeRate.key)
                cell.rateLabel.text = String(exchangeRate.value)
            }
            .disposed(by: disposeBag)
    }
    
    func bindViewModelToViews(){
        viewModel.fromCurrencyOutPutRelay.bind(to: fromAmountCurrencyTextField.rx.text).disposed(by: disposeBag)
        viewModel.toCurrencyOutPutRelay.bind(to: toAmountCurrencyTextField.rx.text).disposed(by: disposeBag)
        
        //A3takd l streen l ta7t dol malohmsh lazma
        viewModel.fromCurrencyRelay.bind(to: fromCurrencyTypeDropList.rx.text).disposed(by: disposeBag)
        viewModel.toCurrencyRelay.bind(to: toCurrencyTypeDropList.rx.text).disposed(by: disposeBag)
    }
    
    func bindViewsToViewModel(){
        
        fromAmountCurrencyTextField.rx
            .text
            .orEmpty
            .map { $0.isEmpty ? "0.0" : $0 }
            .compactMap(Double.init)
            .bind(to: viewModel.fromAmountRelay)
            .disposed(by: disposeBag)
        
        toAmountCurrencyTextField.rx
            .text
            .orEmpty
            .map { $0.isEmpty ? "0.0" : $0 }
            .compactMap(Double.init)
            .bind(to: viewModel.toAmountRelay)
            .disposed(by: disposeBag)
        
        fromCurrencyTypeDropList.rx
            .text
            .orEmpty
            .bind(to: viewModel.fromCurrencyRelay)
            .disposed(by: disposeBag)
        
        toCurrencyTypeDropList.rx
            .text
            .orEmpty
            .bind(to: viewModel.toCurrencyRelay)
            .disposed(by: disposeBag)
        
    }
}

extension ConvertWithNibFileVC{
    func fillDropList(){
        viewModel.allOfCurrencies
            .subscribe { currencyArray in
                print(self.viewModel.fillDropDown(currencyArray: currencyArray))
                self.fromCurrencyTypeDropList.optionArray = self.viewModel.fillDropDown(currencyArray: currencyArray)
                self.toCurrencyTypeDropList.optionArray = self.viewModel.fillDropDown(currencyArray: currencyArray)
                
            }
            .disposed(by: disposeBag)
    }
}

extension ConvertWithNibFileVC{
    func setUp(){
        fromAmountCurrencyTextField.addLeftPadding(padding: 5)
        toAmountCurrencyTextField.addLeftPadding(padding: 5)
    }
    
    func bindViewToViewModellll(){
        viewModel.conversion.bind(to: toAmountCurrencyTextField.rx.text).disposed(by: disposeBag)
    }
}
