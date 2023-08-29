//
//  ViewController.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 22/08/2023.
//

import RxCocoa
import RxSwift
import SDWebImage
import UIKit

class ParentVC: UIViewController {
    @IBOutlet weak var concurrencyTitleLabel: UILabel!
    @IBOutlet weak var currencyConverterLabel: UILabel!
    @IBOutlet weak var checkLiveForeignCurrencyLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerViewForConvertAndCompare: UIView!
    
    var firstVC = ConvertWithNibFileVC(nibName: "Convert", bundle: nil)
    var secondVC = CompareWithNibFileVC(nibName: "Compare", bundle: nil)
    
    var viewModel = ConvertViewModel()
    let disposeBag = DisposeBag()
    let convertButtonPressed = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedString()
        func handleErrors() {
            let errorTitle = NSLocalizedString("ERROR_TITLE", comment: "")

            viewModel.errorSubject
            
                .subscribe { error in
                    self.show(messageAlert: errorTitle, message: error.localizedDescription)
                }
                .disposed(by: disposeBag)
        }
        
        addChild(firstVC)
        addChild(secondVC)
        
        firstVC.view.frame = containerViewForConvertAndCompare.bounds
        secondVC.view.frame = containerViewForConvertAndCompare.bounds
        
        containerViewForConvertAndCompare.addSubview(firstVC.view)
        containerViewForConvertAndCompare.addSubview(secondVC.view)
        
        firstVC.didMove(toParent: self)
        secondVC.didMove(toParent: self)
        
        showViewController(firstVC)
        
        concurrencyTitleLabel.font = UIFont(name: "Memphis-Bold", size: 21)
        currencyConverterLabel.font = UIFont(name: "MontserratRoman-SemiBold", size: 22)
        checkLiveForeignCurrencyLabel.font = UIFont(name: "MontserratRoman-Regular", size: 12.78)
        
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 13.8)]
        
        segmentedControl.setTitleTextAttributes(attributes, for: .normal)
        
        // fromCurrencyTextField.text = "\(usdEmoji) USD"
        // toCurrencyTextField.text = "\(egpEmoji) EGP"
        // viewModel.fetchAllCurrencies()
        // viewModel.fetchCurrency()
        // bindTableViewToViewModel()
        // viewModel.fromUSDtoEGP()
        // bindViewModelToViews()
        // bindViewsToViewModel()
        // favoritesCurrenciesTableView.register(UINib(nibName: "CurrencyCell", bundle: nil), forCellReuseIdentifier: "currencyCell")
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            showViewController(firstVC)
        case 1:
            showViewController(secondVC)
        default:
            break
        }
    }
    
    private func showViewController(_ viewControllerToShow: UIViewController) {
        for vc in children {
            vc.view.isHidden = true
        }
        viewControllerToShow.view.isHidden = false
    }
}

private extension ParentVC {
    func localizedString() {
        let concurrencyTitle = NSLocalizedString("CONCURRENCY_TITLE", comment: "")
        concurrencyTitleLabel.text = concurrencyTitle
        
        let currencyConverterTitle = NSLocalizedString("CONCURRENCY_CONVERTER_TITLE", comment: "")
        currencyConverterLabel.text = currencyConverterTitle
        
        let liveForeignCurrencyExchangeRatesTitle = NSLocalizedString("CHECK_LIVE_RATES_TITLE", comment: "")
        checkLiveForeignCurrencyLabel.text = liveForeignCurrencyExchangeRatesTitle
        
        segmentedControl.setTitle(NSLocalizedString("CONVERT_TITLE", comment: ""), forSegmentAt: 0)
        segmentedControl.setTitle(NSLocalizedString("COMPARE_TITLE", comment: ""), forSegmentAt: 1)
    }
}
