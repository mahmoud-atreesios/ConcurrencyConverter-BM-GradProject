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

class ConvertWithNibFileVC: UIViewController {
        
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
        

        
        bindViewToViewModellll()
        setUpIntialValueForDropList()
        setUpLoader()
        resetToAmountTextField()
        fromAmountCurrencyTextField.text = ""
        bindViewsToViewModel()
        bindTableViewToViewModel()
        //showFavouriteData()
        
        let cornerRadius: CGFloat = 20
        let textFieldHeight: CGFloat = 48
        let borderColor = UIColor(red: 0.773, green: 0.773, blue: 0.773, alpha: 1).cgColor
        let borderWidth: CGFloat = 0.5
        let padding: CGFloat = 15
        
        configureTextField(fromAmountCurrencyTextField, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        configureTextField(toAmountCurrencyTextField, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        
        configureDropDown(fromCurrencyTypeDropList, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        configureDropDown(toCurrencyTypeDropList, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        
        
        fillDropList()
        viewModel.fetchAllCurrencies()
        viewModel.fetchCurrency()
        //bindTableViewToViewModel()
        
        selectedFavouriteCurrenciesTableView.register(UINib(nibName: "CurrencyCell", bundle: nil), forCellReuseIdentifier: "currencyCell")
    }

    @IBAction func convertButtonPressed(_ sender: UIButton) {
        //viewModel.convertButtonPressedRelay.accept(())
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
            // If the network is unavailable, start the loader
            DispatchQueue.main.async {
                self.loader.startAnimating()
            }

        } else {
            // If the network is available, stop the loader and call convertCurrency
            loader.stopAnimating()
            viewModel.convertCurrency(amount: fromAmount, from: String(fromCurrencyText.dropFirst(2)), to: String(toCurrencyText.dropFirst(2)))
        }
//        viewModel.convertCurrency(amount: fromAmount, from: String(fromCurrencyText.dropFirst(2)), to: String(toCurrencyText.dropFirst(2)))
        
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
        
        testViewModel.shared().favouriteItems
            .bind(to: selectedFavouriteCurrenciesTableView.rx.items(cellIdentifier: "currencyCell", cellType: CurrencyCell.self)){
                (row,curr,cell) in
                if let favoriteFromCurrency = UserDefaults.standard.string(forKey: "favoriteFromCurrency") {
                    guard let arr = AppConfigs.dict[favoriteFromCurrency] else { return }
                    cell.rateLabel.text = "\(arr[curr.currencyCode] ?? 0)"
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
    
    func bindViewToViewModellll(){
        viewModel.conversion.bind(to: toAmountCurrencyTextField.rx.text).disposed(by: disposeBag)
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
}

extension ConvertWithNibFileVC{
//    func showFavouriteData(){
//        viewModel.favouriteItems
//            .bind(to: selectedFavouriteCurrenciesTableView.rx.items(cellIdentifier: "currencyCell", cellType: CurrencyCell.self)){
//                (row,curr,cell) in
//                if let url = URL(string: curr.flagURL){
//                    cell.currencyFlagImageView.sd_setImage(with: url)
//                }
//                cell.currencyLabel.text = curr.currencyCode
//                Observable.combineLatest(self.viewModel.fromAmountRelay, self.viewModel.fromCurrencyRelay)
//                    .subscribe(onNext: {
//                        (amount , fromCurrency) in
//                        self.viewModel.getConvertionRate(amount: amount, from: fromCurrency, to: curr.currencyCode) { conversionRate in
//                            cell.rateLabel.text = conversionRate
//                        }
//                    })
//                    .disposed(by: self.disposeBag)
//            }
//            .disposed(by: disposeBag)
//
//        testViewModel.shared().favouriteItems
//            .map { $0.isEmpty }
//            .subscribe(onNext: { [weak self] isEmpty in
//                if isEmpty {
//                    let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self?.selectedFavouriteCurrenciesTableView.bounds.size.width ?? 0, height: self?.selectedFavouriteCurrenciesTableView.bounds.size.height ?? 0))
//                    noDataLabel.text = "No currencies added"
//                    noDataLabel.textColor = UIColor(red: 0.773, green: 0.773, blue: 0.773, alpha: 1)
//                    noDataLabel.textAlignment = .center
//                    self?.selectedFavouriteCurrenciesTableView.backgroundView = noDataLabel
//                    self?.selectedFavouriteCurrenciesTableView.separatorStyle = .none
//                } else {
//                    self?.selectedFavouriteCurrenciesTableView.backgroundView = nil
//                    self?.selectedFavouriteCurrenciesTableView.separatorStyle = .singleLine
//                }
//            })
//            .disposed(by: disposeBag)
//    }
}

//Observable.combineLatest(self.currencyVM.fromAmount, self.currencyVM.fromCurrency)
//                        .subscribe(onNext: { (amount, fromCurrency) in
//                            self.currencyVM.getConvertionRate(amount: amount, from: fromCurrency, to: curr.currencyCode) { converstionRate in
//                                cell.currencyAmountLabel.text = converstionRate
//                            }
//                        })
//                        .disposed(by: disposeBag)
