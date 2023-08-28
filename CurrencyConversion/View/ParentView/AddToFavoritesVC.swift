//
//  AddToFavoritesVC.swift
//  CurrencyConversion
//
//  Created by Hend on 25/08/2023.
//

import RealmSwift
import RxCocoa
import RxSwift
import SDWebImage
import SDWebImageSVGCoder
import UIKit

class AddToFavoritesVC: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var myFavoritesLabel: UILabel!
    @IBOutlet weak var favoritesContainerUIView: UIView!
    @IBOutlet weak var selectedFavouritesCurrenciesTableView: UITableView!

    let viewModel = ConvertViewModel()
    let disposeBag = DisposeBag()
    // let test = testViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        myFavoritesLabel.font = UIFont(name: "Poppins-Medium", size: 17.34)
        closeButton.titleLabel?.frame = CGRect(x: 0, y: 0, width: 20.37, height: 20.37)

        print(FavouriteCurrenciesManager.shared().returnDataBaseURL())
        favoritesContainerUIView.layer.cornerRadius = 25
        setupSVG()
        viewModel.fetchAllCurrencies()
        bindTableViewToViewModel()
        selectedFavouritesCurrenciesTableView.register(UINib(nibName: "FavoriteCurrenciesTableViewCell", bundle: nil), forCellReuseIdentifier: "favoriteCell")
    }

    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension AddToFavoritesVC {
    func bindTableViewToViewModel() {
        print("ana gwa l function")
        viewModel.allOfCurrencies
            .bind(to: selectedFavouritesCurrenciesTableView.rx.items(cellIdentifier: "favoriteCell", cellType: FavoriteCurrenciesTableViewCell.self)) {
                _, currency, cell in
                let favoriteModel = FavouriteModel(currencyCode: currency.code, flagURL: currency.flagURL)
                cell.currencyLabel.text = currency.desc
                cell.currencyCode.text = currency.code
                if let url = URL(string: currency.flagURL) {
                    cell.currencyFlagImageView.sd_setImage(with: url)
                }
                cell.checkButton.isChecked = FavouriteCurrenciesManager.shared().isItemFavorited(favoriteModel)
                cell.checkbuttonPressed = {
                    if cell.checkButton.isChecked {
                        FavouriteCurrenciesManager.shared().addRealmCurrency(favoriteModel)
                        // print("Added \(currency.code) to favorites")
                    } else {
                        FavouriteCurrenciesManager.shared().deleteRealmCurrency(favoriteModel)
                        print("deleted \(currency.code) from favorites")
                    }
                    // self.viewModel.favouriteItems.accept(FavouriteCurrenciesManager.shared().getAllFavouritesItems())
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
