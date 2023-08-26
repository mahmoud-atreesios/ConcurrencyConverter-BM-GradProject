//
//  ViewController.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 22/08/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage

class ParentVC: UIViewController {
    
    var firstVC = ConvertWithNibFileVC(nibName: "Convert", bundle: nil)
    var secondVC = CompareWithNibFileVC(nibName: "Compare", bundle: nil)
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerViewForConvertAndCompare: UIView!
    
    var viewModel = ConvertViewModel()
    let disposeBag = DisposeBag()
    let convertButtonPressed = PublishSubject<Void>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ConvertViewModel()
        
        addChild(firstVC)
        addChild(secondVC)
        
        firstVC.view.frame = containerViewForConvertAndCompare.bounds
        secondVC.view.frame = containerViewForConvertAndCompare.bounds
        
        containerViewForConvertAndCompare.addSubview(firstVC.view)
        containerViewForConvertAndCompare.addSubview(secondVC.view)
        
        firstVC.didMove(toParent: self)
        secondVC.didMove(toParent: self)
        
        showViewController(firstVC)
        
        //fromCurrencyTextField.text = "\(usdEmoji) USD"
        //toCurrencyTextField.text = "\(egpEmoji) EGP"
        //viewModel.fetchAllCurrencies()
        //viewModel.fetchCurrency()
        // bindTableViewToViewModel()
        //viewModel.fromUSDtoEGP()
        //bindViewModelToViews()
        //bindViewsToViewModel()
        //favoritesCurrenciesTableView.register(UINib(nibName: "CurrencyCell", bundle: nil), forCellReuseIdentifier: "currencyCell")
        
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
        // Hide all view controllers
        for vc in children {
            vc.view.isHidden = true
        }
        
        // Show the selected view controller
        viewControllerToShow.view.isHidden = false
    }
    

    //    func handleAddToFavoritesButtonPressed() {
    //        let sb = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your actual storyboard name
    //        let addToFavoritesVC = sb.instantiateViewController(withIdentifier: "AddToFavoritesVC") as! AddToFavoritesVC
    //
    //        self.present(addToFavoritesVC, animated: true, completion: nil)
    //    }
}

