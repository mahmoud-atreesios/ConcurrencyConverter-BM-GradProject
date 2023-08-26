////
////  test.swift
////  CurrencyConversion
////
////  Created by Mahmoud Mohamed Atrees on 26/08/2023.
////
//
//import Foundation
////
////  ViewController.swift
////  CurrencyConversion
////
////  Created by Mahmoud Mohamed Atrees on 22/08/2023.
////
//
//import UIKit
//import RxSwift
//import RxCocoa
//import SDWebImage
//
//class ParentVC: UIViewController {
//    
//    let firstVC = ConvertWithNibFileVC(nibName: "Convert", bundle: nil)
//    let secondVC = CompareWithNibFileVC(nibName: "Compare", bundle: nil)
//
//    @IBOutlet weak var segmentedControl: UISegmentedControl!
//    @IBOutlet weak var containerViewForConvertAndCompare: UIView!
//
//
//    var viewModel = ConvertViewModel()
//    let disposeBag = DisposeBag()
//    let convertButtonPressed = PublishSubject<Void>()
//
//    let usdEmoji = currencyCodeToEmoji("US") // 🇺🇸
//    let egpEmoji = currencyCodeToEmoji("EG") // 🇪🇬
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        viewModel = ConvertViewModel()
//
//        addChild(firstVC)
//        addChild(secondVC)
//
//        firstVC.view.frame = containerViewForConvertAndCompare.bounds
//        secondVC.view.frame = containerViewForConvertAndCompare.bounds
//
//        containerViewForConvertAndCompare.addSubview(firstVC.view)
//        containerViewForConvertAndCompare.addSubview(secondVC.view)
//
//        firstVC.didMove(toParent: self)
//        secondVC.didMove(toParent: self)
//
//        showViewController(firstVC)
//
//        //fromCurrencyTextField.text = "\(usdEmoji) USD"
//        //toCurrencyTextField.text = "\(egpEmoji) EGP"
//        print(usdEmoji)
//        //viewModel.fetchAllCurrencies()
//        //viewModel.fetchCurrency()
//        // bindTableViewToViewModel()
//        //viewModel.fromUSDtoEGP()
//        //bindViewModelToViews()
//        //bindViewsToViewModel()
//        //favoritesCurrenciesTableView.register(UINib(nibName: "CurrencyCell", bundle: nil), forCellReuseIdentifier: "currencyCell")
//
//    }
//
//    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
//        switch segmentedControl.selectedSegmentIndex {
//        case 0:
//            showViewController(firstVC)
//        case 1:
//            showViewController(secondVC)
//        default:
//            break
//        }
//    }
//
//    private func showViewController(_ viewControllerToShow: UIViewController) {
//        // Hide all view controllers
//        for vc in children {
//            vc.view.isHidden = true
//        }
//
//        // Show the selected view controller
//        viewControllerToShow.view.isHidden = false
//    }
//
//    func handleAddToFavoritesButtonPressed() {
//        let sb = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your actual storyboard name
//        let addToFavoritesVC = sb.instantiateViewController(withIdentifier: "AddToFavoritesVC") as! AddToFavoritesVC
//
//        self.present(addToFavoritesVC, animated: true, completion: nil)
//    }
//}
//
//
//
////MARK: Binding Section
//extension ParentVC{
//
//    //    func bindViewModelToViews(){
//    //        viewModel.fromCurrencyOutPutRelay.bind(to: fromAmountTextField.rx.text).disposed(by: disposeBag)
//    //        viewModel.toCurrencyOutPutRelay.bind(to: toAmountTextField.rx.text).disposed(by: disposeBag)
//    //
//    //        //A3takd l streen l ta7t dol malohmsh lazma
//    //        viewModel.fromCurrencyRelay.bind(to: fromCurrencyTextField.rx.text).disposed(by: disposeBag)
//    //        viewModel.toCurrencyRelay.bind(to: toCurrencyTextField.rx.text).disposed(by: disposeBag)
//    //    }
//
//    //    func bindViewsToViewModel(){
//    //
//    //        fromAmountTextField.rx
//    //            .text
//    //            .orEmpty
//    //            .map { $0.isEmpty ? "0.0" : $0 }
//    //            .compactMap(Double.init)
//    //            .bind(to: viewModel.fromAmountRelay)
//    //            .disposed(by: disposeBag)
//    //
//    //        toAmountTextField.rx
//    //            .text
//    //            .orEmpty
//    //            .map { $0.isEmpty ? "0.0" : $0 }
//    //            .compactMap(Double.init)
//    //            .bind(to: viewModel.toAmountRelay)
//    //            .disposed(by: disposeBag)
//    //
//    //        fromCurrencyTextField.rx
//    //            .text
//    //            .orEmpty
//    //            .bind(to: viewModel.fromCurrencyRelay)
//    //            .disposed(by: disposeBag)
//    //
//    //        toCurrencyTextField.rx
//    //            .text
//    //            .orEmpty
//    //            .bind(to: viewModel.toCurrencyRelay)
//    //            .disposed(by: disposeBag)
//    //
//    //    }
//    //
//
//    //    func bindTableViewToViewModel(){
//    //
////            viewModel.allOfCurrencies
////                .bind(to: favoritesCurrenciesTableView.rx.items(cellIdentifier: "currencyCell", cellType: CurrencyCell.self)){ (row, currency, cell) in
////                    cell.currencyLabel.text = String(currency.desc)
////                    cell.rateLabel.text = String(currency.code)
////                    if let url = URL(string: currency.flagURL) {
////                        cell.currencyFlagImageView.sd_setImage(with: url, completed: nil)
////                    }
////                    //cell.currencyFlagImageView.image = UIImage(named: String(currency.flagURL))
////                }
////                .disposed(by: disposeBag)
////
//    //        viewModel.currencyRates
//    //            .bind(to: favoritesCurrenciesTableView.rx.items(cellIdentifier: "currencyCell", cellType: CurrencyCell.self)){
//    //                (row,exchangeRate,cell) in
//    //                cell.baseLabel.text = "Currency"
//    //                cell.currencyLabel.text = "USD"
//    //                cell.rateLabel.text = "99.5"
//    //                cell.currencyLabel.text = String(exchangeRate.key)
//    //                cell.rateLabel.text = String(exchangeRate.value)
//    //            }
//    //            .disposed(by: disposeBag)
//    // }
//}
//
//extension ParentVC{
//    static func currencyCodeToEmoji(_ code: String) -> String {
//        let base: UInt32 = 127397
//        var emoji = ""
//        for scalar in code.unicodeScalars {
//            emoji.append(String(UnicodeScalar(base + scalar.value)!))
//        }
//        return emoji
//    }
//
//}
