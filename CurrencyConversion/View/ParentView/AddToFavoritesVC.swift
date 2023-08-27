//
//  AddToFavoritesVC.swift
//  CurrencyConversion
//
//  Created by Hend on 25/08/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage
import SDWebImageSVGCoder
import RealmSwift

class AddToFavoritesVC: UIViewController {
    
    @IBOutlet weak var favoritesContainerUIView: UIView!
    @IBOutlet weak var selectedFavouritesCurrenciesTableView: UITableView!
    
//    var viewModel: ConvertViewModel
//
//        init(viewModel: ConvertViewModel){
//            self.viewModel = viewModel
//            super.init(nibName: "FavouritesScreenVC", bundle: .main)
//        }
//
//        required init?(coder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
    
    let viewModel = ConvertViewModel()
    let disposeBag = DisposeBag()
    //let test = testViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FavouriteCurrenciesManager.shared().returnDataBaseURL()) 
        favoritesContainerUIView.layer.cornerRadius = 25
        setupSVG()
        viewModel.fetchAllCurrencies()
        //viewModel. .fetchAllCurrencies()
        bindTableViewToViewModel()
        selectedFavouritesCurrenciesTableView.register(UINib(nibName: "FavoriteCurrenciesTableViewCell", bundle: nil), forCellReuseIdentifier: "favoriteCell")
    }
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
}

extension AddToFavoritesVC{
    
    func bindTableViewToViewModel() {
        print("ana gwa l function")
        viewModel.allOfCurrencies
            .bind(to: selectedFavouritesCurrenciesTableView.rx.items(cellIdentifier: "favoriteCell", cellType: FavoriteCurrenciesTableViewCell.self)){
                (row, currency, cell) in
                let favoriteModel = FavouriteModel(currencyCode: currency.code, flagURL: currency.flagURL)
                cell.currencyLabel.text = currency.desc
                cell.currencyCode.text = currency.code
                if let url = URL(string: currency.flagURL) {
                    cell.currencyFlagImageView.sd_setImage(with: url)
                }
                    cell.checkButton.isChecked = FavouriteCurrenciesManager.shared().isItemFavorited(favoriteModel)
                    cell.checkbuttonPressed = {
                        if cell.checkButton.isChecked{
                            FavouriteCurrenciesManager.shared().addRealmCurrency(favoriteModel)
                            //print("Added \(currency.code) to favorites")
                        }else{
                            FavouriteCurrenciesManager.shared().deleteRealmCurrency(favoriteModel)
                            print("deleted \(currency.code) from favorites")
                        }
                        //self.viewModel.favouriteItems.accept(FavouriteCurrenciesManager.shared().getAllFavouritesItems())
                        testViewModel.shared().favouriteItems.accept(FavouriteCurrenciesManager.shared().getAllFavouritesItems())
                    }
                
            }
            .disposed(by: disposeBag)
    }
    func setupSVG() {
        let SVGCoder = SDImageSVGCoder.shared
        SDImageCodersManager.shared.addCoder(SVGCoder)
    }
}

