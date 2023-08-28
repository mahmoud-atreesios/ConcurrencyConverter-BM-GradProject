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
import SDWebImage
import SDWebImageSVGCoder
import Reachability

class ConvertWithNibFileVC: UIViewController{
    
    @IBOutlet weak var fromAmountCurrencyTextField: UITextField!
    @IBOutlet weak var fromCurrencyTypeDropList: DropDown!
    
    @IBOutlet weak var toAmountCurrencyTextField: UITextField!
    @IBOutlet weak var toCurrencyTypeDropList: DropDown!
    
    @IBOutlet weak var selectedFavouriteCurrenciesTableView: UITableView!
    
    let viewModel = ConvertViewModel()
    let disposeBag = DisposeBag()
    let favouriteItems = FavouriteCurrenciesManager.shared().getAllFavouritesItems()
    
    var loader: UIActivityIndicatorView!
    let reachability = try! Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let favoriteFromCurrency = UserDefaults.standard.rx.observe(String.self, "favoriteFromCurrency")
            .distinctUntilChanged()
        
        favoriteFromCurrency
            .subscribe(onNext: { [weak self] newBaseCurrency in
                self?.viewModel.fetchCurrency()
            })
            .disposed(by: disposeBag)
        
        bindViewToViewModellll()
        setUpIntialValueForDropList()
        setUpLoader()
        resetToAmountTextField()
        fromAmountCurrencyTextField.text = ""
        bindViewsToViewModel()
        bindTableViewToViewModel()
        
        setUp()
        
        fillDropList()
        viewModel.fetchAllCurrencies()
        
        selectedFavouriteCurrenciesTableView.register(UINib(nibName: "CurrencyCell", bundle: nil), forCellReuseIdentifier: "currencyCell")
        handleErrors()
    }
    
    @IBAction func convertButtonPressed(_ sender: UIButton) {
        let fromValue = String(fromCurrencyTypeDropList.text?.dropFirst(2) ?? "")
        let toValue = String(toCurrencyTypeDropList.text?.dropFirst(2) ?? "")
        
        UserDefaults.standard.setValue(fromValue, forKey: "favoriteFromCurrency")
        UserDefaults.standard.setValue(toValue, forKey: "favoriteToCurrency")
        
        guard let fromCurrencyText = fromCurrencyTypeDropList.text, !fromCurrencyText.isEmpty,
              let toCurrencyText = toCurrencyTypeDropList.text, !toCurrencyText.isEmpty else {
            return
        }
        
        var fromAmount = fromAmountCurrencyTextField.text ?? "0.0"
        if fromAmount.isEmpty {
            fromAmount = "0.0"
        }
        
        if reachability.connection == .unavailable {
            DispatchQueue.main.async {
                self.loader.startAnimating()
            }
            
        } else {
            loader.stopAnimating()
            viewModel.convertCurrency(amount: fromAmount, from: String(fromCurrencyText.dropFirst(2)), to: String(toCurrencyText.dropFirst(2)))
        }
    }
    
    @IBAction func addToFavouritesButtonPressed(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let profileScreen = sb.instantiateViewController(withIdentifier: "AddToFavoritesVC") as! AddToFavoritesVC
        self.present(profileScreen, animated: true)
        
    }
    
    func bindViewToViewModellll(){
        viewModel.conversion.bind(to: toAmountCurrencyTextField.rx.text).disposed(by: disposeBag)
    }
    
}

extension ConvertWithNibFileVC{
    func bindTableViewToViewModel() {
        
        testViewModel.shared().favouriteItems
            .bind(to: selectedFavouriteCurrenciesTableView.rx.items(cellIdentifier: "currencyCell", cellType: CurrencyCell.self)){
                (row,curr,cell) in
                if let favoriteFromCurrency = UserDefaults.standard.string(forKey: "favoriteFromCurrency") {
                    guard let arr = AppConfigs.dict[favoriteFromCurrency] else { return }
                    cell.rateLabel.text =  String(format: "%.4f", arr[curr.currencyCode] ?? 0)
                }
                cell.baseLabel.text = "Currency"
                cell.currencyLabel.text = curr.currencyCode
                if let url = URL(string: curr.flagURL) {
                    cell.currencyFlagImageView.sd_setImage(with: url)
                }
            }
            .disposed(by: disposeBag)
        
        testViewModel.shared().favouriteItems
            .map { $0.isEmpty }
            .subscribe(onNext: { [weak self] isEmpty in
                if isEmpty {
                    let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self?.selectedFavouriteCurrenciesTableView.bounds.size.width ?? 0, height: self?.selectedFavouriteCurrenciesTableView.bounds.size.height ?? 0))
                    noDataLabel.text = "No currencies added"
                    noDataLabel.textColor = UIColor(red: 0.773, green: 0.773, blue: 0.773, alpha: 1)
                    noDataLabel.textAlignment = .center
                    self?.selectedFavouriteCurrenciesTableView.backgroundView = noDataLabel
                    self?.selectedFavouriteCurrenciesTableView.separatorStyle = .none
                } else {
                    self?.selectedFavouriteCurrenciesTableView.backgroundView = nil
                    self?.selectedFavouriteCurrenciesTableView.separatorStyle = .singleLine
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindViewsToViewModel(){
        
        fromAmountCurrencyTextField.rx.controlEvent(.editingChanged)
            .withLatestFrom(fromAmountCurrencyTextField.rx.text.orEmpty)
            .map { currency in
                let cleanedCurrency = String(currency.dropFirst(2))
                return cleanedCurrency.isEmpty ? "0.0" : cleanedCurrency
            }
            .distinctUntilChanged()
            .compactMap(Double.init)
            .bind(to: viewModel.fromAmountRelay)
            .disposed(by: disposeBag)
        
        fromCurrencyTypeDropList.rx.text.orEmpty
            .map { currency in
                let cleanedCurrency = String(currency.dropFirst(2))
                return cleanedCurrency.isEmpty ? "0.0" : cleanedCurrency
            }
            .distinctUntilChanged()
            .bind(to: viewModel.fromCurrencyRelay)
            .disposed(by: disposeBag)
        
    }
}

extension ConvertWithNibFileVC{
    func fillDropList(){
        viewModel.allOfCurrencies
            .subscribe { currencyArray in
                //print(self.viewModel.fillDropDown(currencyArray: currencyArray))
                self.fromCurrencyTypeDropList.optionArray = self.viewModel.fillDropDown(currencyArray: currencyArray)
                self.toCurrencyTypeDropList.optionArray = self.viewModel.fillDropDown(currencyArray: currencyArray)
                
            }
            .disposed(by: disposeBag)
    }
}

extension ConvertWithNibFileVC{
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
        
        toAmountCurrencyTextField.isUserInteractionEnabled = false
        
        let cornerRadius: CGFloat = 20
        let textFieldHeight: CGFloat = 48
        let borderColor = UIColor(red: 0.773, green: 0.773, blue: 0.773, alpha: 1).cgColor
        let borderWidth: CGFloat = 0.5
        let padding: CGFloat = 15
        
        configureTextField(fromAmountCurrencyTextField, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        configureTextField(toAmountCurrencyTextField, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        
        configureDropDown(fromCurrencyTypeDropList, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        configureDropDown(toCurrencyTypeDropList, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
    }
}

extension ConvertWithNibFileVC{
    func setUpIntialValueForDropList(){
        let favoriteFromCurrency = UserDefaults.standard.string(forKey: "favoriteFromCurrency") ?? "USD"
        let favoriteToCurrency = UserDefaults.standard.string(forKey: "favoriteToCurrency") ?? "EGP"
        fromCurrencyTypeDropList.text = " " + viewModel.getFlagEmoji(flag: favoriteFromCurrency) + favoriteFromCurrency
        toCurrencyTypeDropList.text = " " + viewModel.getFlagEmoji(flag: favoriteToCurrency) + favoriteToCurrency
    }
    
    func resetToAmountTextField(){
        fromAmountCurrencyTextField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] _ in
                self?.toAmountCurrencyTextField.text = ""
            })
            .disposed(by: disposeBag)
    }
    
    func handleErrors(){
        viewModel.errorSubject
            .subscribe { error in
                self.show(messageAlert: "Error", message: error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
}

