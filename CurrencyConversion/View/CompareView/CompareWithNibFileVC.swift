//
//  CompareWithNibFileVC.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 25/08/2023.
//

import iOSDropDown
import Reachability
import RxCocoa
import RxSwift
import UIKit

class CompareWithNibFileVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var targetedCurrencyTwo: UILabel!
    @IBOutlet weak var targetedCurrencyOne: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var compareButton: UIButton!
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
        fromAmountTextField.delegate = self
        
        localizedString()
        setUp()
        setUpLoader()
        viewModel.fetchAllCurrencies()
        viewModel.fetchCurrency()
        setUpIntialValueForDropList()
        fillDropList()
        resetToAmountTextField()
        
        bindViewToViewModel()
        
        handleErrors()
        hideKeyboardWhenTappedAround()

    }
    
    @IBAction func compareButtonPressed(_ sender: UIButton) {
        guard let fromCurrencyText = fromCurrencyDropList.text, !fromCurrencyText.isEmpty,
              let toFirstCurrencyText = toFirstCurrencyTypeDropList.text, !toFirstCurrencyText.isEmpty
        else {
            return
        }
        guard let toSecondCurrencyText = toSecondCurrencyTypeDropList.text, !toSecondCurrencyText.isEmpty else {
            return
        }
        guard let fromAmount = fromAmountTextField.text , !fromAmount.isEmpty else{
            let emptyFieldTitle = NSLocalizedString("PLEASE_ENTER_NUMBER_LABEL", comment: "")
            show(messageAlert: "", message: emptyFieldTitle)
            return
        }
        
        if reachability.connection == .unavailable {
            print("there is no network connection")
//            DispatchQueue.main.async {
//                self.loader.startAnimating()
//            }
            
        } else {
            //loader.stopAnimating()
            print("there is good network connection")
            viewModel.compareCurrency(amount: fromAmount, from: String(fromCurrencyText.dropFirst(2)), toFirstCurrency: String(toFirstCurrencyText.dropFirst(2)), toSecondCurrency: String(toSecondCurrencyText.dropFirst(2)))
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return NumericInputFilter.filterInput(string)
    }
}

extension CompareWithNibFileVC {
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
        
        firstToAmountTextField.isUserInteractionEnabled = false
        secondToAmountTextField.isUserInteractionEnabled = false

        configureTextField(fromAmountTextField, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        configureTextField(firstToAmountTextField, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        
        configureDropDown(fromCurrencyDropList, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        configureDropDown(toFirstCurrencyTypeDropList, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        
        configureDropDown(toSecondCurrencyTypeDropList, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)
        configureTextField(secondToAmountTextField, cornerRadius: cornerRadius, height: textFieldHeight, borderWidth: borderWidth, borderColor: borderColor, padding: padding)

        
        amountLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        fromLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        targetedCurrencyOne.font = UIFont(name: "Poppins-SemiBold", size: 14)
        targetedCurrencyTwo.font = UIFont(name: "Poppins-SemiBold", size: 14)
        
        firstToAmountTextField.font = UIFont(name: "Poppins-SemiBold", size: 16)
        secondToAmountTextField.font = UIFont(name: "Poppins-SemiBold", size: 16)
        fromAmountTextField.font = UIFont(name: "Poppins-SemiBold", size: 16)
        
        fromCurrencyDropList.font = UIFont(name: "Poppins-Regular", size: 16)
        toFirstCurrencyTypeDropList.font = UIFont(name: "Poppins-Regular", size: 16)
        toSecondCurrencyTypeDropList.font = UIFont(name: "Poppins-Regular", size: 16)
        compareButton.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 16)
    }
    
}

extension CompareWithNibFileVC{
    
    func bindViewToViewModel(){
        viewModel.firstComparedCurrency.bind(to: firstToAmountTextField.rx.text).disposed(by: disposeBag)
        viewModel.secoundComparedCurrency.bind(to: secondToAmountTextField.rx.text).disposed(by: disposeBag)
        
    }
    
    func setUpIntialValueForDropList() {

        fromCurrencyDropList.text = " " + viewModel.getFlagEmoji(flag: "EGP") + "EGP"
        toFirstCurrencyTypeDropList.text = " " + viewModel.getFlagEmoji(flag: "USD") + "USD"
        toSecondCurrencyTypeDropList.text = " " + viewModel.getFlagEmoji(flag: "USD") + "USD"
    }
    
    func fillDropList(){
        
        viewModel.allOfCurrencies
            .subscribe { allCurr in
                self.fromCurrencyDropList.optionArray = self.viewModel.fillDropDown(currencyArray: allCurr)
                self.toFirstCurrencyTypeDropList.optionArray = self.viewModel.fillDropDown(currencyArray: allCurr)
                self.toSecondCurrencyTypeDropList.optionArray = self.viewModel.fillDropDown(currencyArray: allCurr)
            }
            .disposed(by: disposeBag)
    }

    func resetToAmountTextField() {

        fromAmountTextField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] _ in
                self?.firstToAmountTextField.text = ""
                self?.secondToAmountTextField.text = ""
            })
            .disposed(by: disposeBag)
        
        fromCurrencyDropList.didSelect{(selectedText , index ,id) in
            self.firstToAmountTextField.text = ""
            self.secondToAmountTextField.text = ""
        }
        
        toFirstCurrencyTypeDropList.didSelect{(selectedText , index ,id) in
            self.firstToAmountTextField.text = ""
        }
        
        toSecondCurrencyTypeDropList.didSelect{(selectedText , index ,id) in
            self.secondToAmountTextField.text = ""
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(CompareWithNibFileVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

private extension CompareWithNibFileVC {
    func localizedString() {
        let compareTitle = NSLocalizedString("COMPARE_TITLE", comment: "")
        compareButton.setTitle(compareTitle, for: .normal)
        
        let fromTitle = NSLocalizedString("FROM_TITLE", comment: "")
        fromLabel.text = fromTitle
        
        let targetedCurrencyTitle = NSLocalizedString("TARGETED_CURRENCY_TITLE", comment: "")
        targetedCurrencyOne.text = targetedCurrencyTitle
        targetedCurrencyTwo.text = targetedCurrencyTitle
        
        let amountTitle = NSLocalizedString("AMOUNT_TITLE", comment: "")
        amountLabel.text = amountTitle
    }
}
