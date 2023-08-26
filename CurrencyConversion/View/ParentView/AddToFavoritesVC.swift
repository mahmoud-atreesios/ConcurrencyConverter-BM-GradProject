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

class AddToFavoritesVC: UIViewController {
    
    @IBOutlet weak var favoritesContainerUIView: UIView!
    @IBOutlet weak var selectedFavouritesCurrenciesTableView: UITableView!
    
    let viewModel = ConvertViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoritesContainerUIView.layer.cornerRadius = 25
        setupSVG()
        viewModel.fetchAllCurrencies()
        bindTableViewToViewModel()
        selectedFavouritesCurrenciesTableView.register(UINib(nibName: "FavoriteCurrenciesTableViewCell", bundle: nil), forCellReuseIdentifier: "favoriteCell")
    }
}

extension AddToFavoritesVC{
    
    func bindTableViewToViewModel() {
        print("ana gwa l function")
        viewModel.allOfCurrencies
            .bind(to: selectedFavouritesCurrenciesTableView.rx.items(cellIdentifier: "favoriteCell", cellType: FavoriteCurrenciesTableViewCell.self)){
                (row, currency, cell) in
                cell.currencyLabel.text = currency.desc
                cell.currencyCode.text = currency.code
                if let url = URL(string: currency.flagURL) {
                    cell.currencyFlagImageView.sd_setImage(with: url)
                }
            }
            .disposed(by: disposeBag)
    }
    func setupSVG() {
        let SVGCoder = SDImageSVGCoder.shared
        SDImageCodersManager.shared.addCoder(SVGCoder)
    }
}

