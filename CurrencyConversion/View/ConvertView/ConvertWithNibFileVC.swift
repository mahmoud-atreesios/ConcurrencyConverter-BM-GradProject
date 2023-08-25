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
        
        fromAmountCurrencyTextField.text = "100"
        toAmountCurrencyTextField.text = "200"

        fromCurrencyTypeDropList.optionArray = ["A","B","C"]
        toCurrencyTypeDropList.optionArray = ["A","B","C"]
        
        viewModel.fetchAllCurrencies()
        viewModel.fetchCurrency()
        bindTableViewToViewModel()
        selectedFavouriteCurrenciesTableView.register(UINib(nibName: "CurrencyCell", bundle: nil), forCellReuseIdentifier: "currencyCell")
    }
    
    @IBAction func convertButtonPressed(_ sender: UIButton) {
        print("Convert button pressed")
    }

    @IBAction func addToFavouritesButtonPressed(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let profileScreen = sb.instantiateViewController(withIdentifier: "AddToFavoritesVC") as! AddToFavoritesVC
        self.present(profileScreen, animated: true) 
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

}

