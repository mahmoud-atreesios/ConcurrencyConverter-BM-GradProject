//
//  ViewController.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 25/08/2023.
//

import iOSDropDown
import Reachability
import RxCocoa
import RxSwift
import SDWebImage
import SDWebImageSVGCoder
import UIKit

class ConvertWithNibFileVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var myPortofolioLabel: UILabel!
    @IBOutlet weak var convertButton: UIButton!
    @IBOutlet weak var addToFavoritesButton: UIButton!
    @IBOutlet weak var liveExchangeRateLabel: UILabel!
    @IBOutlet weak var amountToLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var amountFromLabel: UILabel!
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
        
        fromAmountCurrencyTextField.delegate = self
        localizedStrings()
        
        setUp()
        setUpLoader()
        setUpIntialValueForDropList()
        fillDropList()
        viewModel.fetchAllCurrencies()
        observeFavoriteCurrencyChange()
        bindViewToViewModel()
        bindTableViewToViewModel()
        resetToAmountTextField()
        hideKeyboardWhenTappedAround()
        handleErrors()
        selectedFavouriteCurrenciesTableView.register(UINib(nibName: "CurrencyCell", bundle: nil), forCellReuseIdentifier: "currencyCell")
    }
    
    @IBAction func convertButtonPressed(_ sender: UIButton) {
        
        let fromValue = String(fromCurrencyTypeDropList.text?.dropFirst(2) ?? "")
        let toValue = String(toCurrencyTypeDropList.text?.dropFirst(2) ?? "")
        
        UserDefaults.standard.setValue(fromValue, forKey: "favoriteFromCurrency")
        UserDefaults.standard.setValue(toValue, forKey: "favoriteToCurrency")
        
        guard let fromCurrencyText = fromCurrencyTypeDropList.text, !fromCurrencyText.isEmpty,
              let toCurrencyText = toCurrencyTypeDropList.text, !toCurrencyText.isEmpty
        else {
            return
        }
        guard let fromAmount = fromAmountCurrencyTextField.text , !fromAmount.isEmpty else{
            let emptyFieldTitle = NSLocalizedString("PLEASE_ENTER_NUMBER_LABEL", comment: "")
            show(messageAlert: "", message: emptyFieldTitle)
            return
        }
        
        if reachability.connection == .unavailable {
            DispatchQueue.main.async {
                print("there is no network connection")
                // self.show(messageAlert: "Error!", message: "error error error")
                // self.loader.startAnimating()
            }
            
        } else {
            print("there is network connection")
            // loader.stopAnimating()
            viewModel.convertCurrency(amount: fromAmount, from: String(fromCurrencyText.dropFirst(2)), to: String(toCurrencyText.dropFirst(2)))
        }
    }
    
    @IBAction func addToFavouritesButtonPressed(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let favoriteScreen = sb.instantiateViewController(withIdentifier: "AddToFavoritesVC") as! AddToFavoritesVC
        present(favoriteScreen, animated: true)
    }
    

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return NumericInputFilter.filterInput(string)
    }
}

//MARK: Binding
extension ConvertWithNibFileVC {
    
    func bindViewToViewModel() {
        viewModel.conversion.bind(to: toAmountCurrencyTextField.rx.text).disposed(by: disposeBag)
    }
    
    func bindTableViewToViewModel() {
        FavouriteManager.shared().favouriteItems
            .bind(to: selectedFavouriteCurrenciesTableView.rx.items(cellIdentifier: "currencyCell", cellType: CurrencyCell.self)) {
                (row ,curr, cell) in
                if let favoriteFromCurrency = UserDefaults.standard.string(forKey: "favoriteFromCurrency") {
                    guard let arr = AppConfigs.dict[favoriteFromCurrency] else { return }
                    cell.rateLabel.text = String(self.viewModel.formattedAndTrimmedValue(arr[curr.currencyCode] ?? 0))
                }
                cell.baseLabel.text = "Currency"
                cell.currencyLabel.text = curr.currencyCode
                if let url = URL(string: curr.flagURL) {
                    cell.currencyFlagImageView.sd_setImage(with: url)
                }
            }
            .disposed(by: disposeBag)
        
        FavouriteManager.shared().favouriteItems
            .map { $0.isEmpty }
            .subscribe(onNext: { [weak self] isEmpty in
                if isEmpty {
                    let noDataLabel: UILabel = .init(frame: CGRect(x: 0, y: 0, width: self?.selectedFavouriteCurrenciesTableView.bounds.size.width ?? 0, height: self?.selectedFavouriteCurrenciesTableView.bounds.size.height ?? 0))
                    noDataLabel.text = "No currencies added"
                    noDataLabel.textColor = UIColor(red: 0.773, green: 0.773, blue: 0.773, alpha: 1)
                    noDataLabel.textAlignment = .center
                    
                    let noCurrencyTitle = NSLocalizedString("NO_FAVORITES_LABEL", comment: "")
                    noDataLabel.text = noCurrencyTitle
                    self?.selectedFavouriteCurrenciesTableView.backgroundView = noDataLabel
                    self?.selectedFavouriteCurrenciesTableView.separatorStyle = .none
                } else {
                    self?.selectedFavouriteCurrenciesTableView.backgroundView = nil
                    self?.selectedFavouriteCurrenciesTableView.separatorStyle = .singleLine
                }
            })
            .disposed(by: disposeBag)
    }
    
    func observeFavoriteCurrencyChange(){
        let favoriteFromCurrency = UserDefaults.standard.rx.observe(String.self, "favoriteFromCurrency")
            .distinctUntilChanged()
        
        favoriteFromCurrency
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.fetchCurrency()
            })
            .disposed(by: disposeBag)
    }
}

//MARK: setUp UI
extension ConvertWithNibFileVC {
    func setUpLoader() {
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
    
    func setUp() {
        let cornerRadius: CGFloat = 20
        let textFieldHeight: CGFloat = 48
        let borderColor = UIColor(red: 0.773, green: 0.773, blue: 0.773, alpha: 1).cgColor
        let borderWidth: CGFloat = 0.5
        let padding: CGFloat = 15
        
        toAmountCurrencyTextField.isUserInteractionEnabled = false
        
        configureTextField(fromAmountCurrencyTextField, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        configureTextField(toAmountCurrencyTextField, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        
        configureDropDown(fromCurrencyTypeDropList, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        configureDropDown(toCurrencyTypeDropList, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        
        amountToLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        amountFromLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        toLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        fromLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        
        fromAmountCurrencyTextField.font = UIFont(name: "Poppins-SemiBold", size: 16)
        toAmountCurrencyTextField.font = UIFont(name: "Poppins-SemiBold", size: 16)
        toCurrencyTypeDropList.font = UIFont(name: "Poppins-Regular", size: 16)
        fromCurrencyTypeDropList.font = UIFont(name: "Poppins-Regular", size: 16)
        liveExchangeRateLabel.font = UIFont(name: "Poppins-SemiBold", size: 16.84)
        myPortofolioLabel.font = UIFont(name: "Poppins-Regular", size: 18)
        convertButton.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 16)
        addToFavoritesButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 10.87)
    }
}

extension ConvertWithNibFileVC {
    func setUpIntialValueForDropList() {
        let favoriteFromCurrency = UserDefaults.standard.string(forKey: "favoriteFromCurrency") ?? "USD"
        let favoriteToCurrency = UserDefaults.standard.string(forKey: "favoriteToCurrency") ?? "EGP"
        fromCurrencyTypeDropList.text = " " + viewModel.getFlagEmoji(flag: favoriteFromCurrency) + favoriteFromCurrency
        toCurrencyTypeDropList.text = " " + viewModel.getFlagEmoji(flag: favoriteToCurrency) + favoriteToCurrency
    }
    
    func fillDropList() {
        viewModel.allOfCurrencies
            .subscribe { currencyArray in
                // print(self.viewModel.fillDropDown(currencyArray: currencyArray))
                self.fromCurrencyTypeDropList.optionArray = self.viewModel.fillDropDown(currencyArray: currencyArray)
                self.toCurrencyTypeDropList.optionArray = self.viewModel.fillDropDown(currencyArray: currencyArray)
            }
            .disposed(by: disposeBag)
    }
    
    func resetToAmountTextField() {
        fromAmountCurrencyTextField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] _ in
                self?.toAmountCurrencyTextField.text = ""
            })
            .disposed(by: disposeBag)
        
        fromCurrencyTypeDropList.didSelect{(selectedText , index ,id) in
            self.toAmountCurrencyTextField.text = ""
        }
        
        toCurrencyTypeDropList.didSelect{(selectedText , index ,id) in
            self.toAmountCurrencyTextField.text = ""
        }
        
    }
    
    func handleErrors() {
        let errorTitle = NSLocalizedString("ERROR_TITLE", comment: "")
        viewModel.errorSubject
            .subscribe { error in
                self.show(messageAlert: errorTitle, message: error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ConvertWithNibFileVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: localization
private extension ConvertWithNibFileVC {
    func localizedStrings() {
        let convertTitle = NSLocalizedString("CONVERT_TITLE", comment: "")
        convertButton.setTitle(convertTitle, for: .normal)
        
        let fromTitle = NSLocalizedString("FROM_TITLE", comment: "")
        fromLabel.text = fromTitle
        
        let toTitle = NSLocalizedString("TO_TITLE", comment: "")
        toLabel.text = toTitle
        
        let amountTitle = NSLocalizedString("AMOUNT_TITLE", comment: "")
        amountToLabel.text = amountTitle
        amountFromLabel.text = amountTitle
        
        let liveExchangeRatesTitle = NSLocalizedString("LIVE_EXCHANGE_RATES_TITLE", comment: "")
        liveExchangeRateLabel.text = liveExchangeRatesTitle
        
        let addToFavoritesLabel = NSLocalizedString("ADD_TO_FAVORITES_TITLE", comment: "")
        addToFavoritesButton.setTitle(addToFavoritesLabel, for: .normal)
        
        let myPortofolioTitle = NSLocalizedString("MY_PORTOFOLIO_TITLE", comment: "")
        myPortofolioLabel.text = myPortofolioTitle
    }
}
