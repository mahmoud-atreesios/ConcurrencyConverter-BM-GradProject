//
//  FavoriteCurrenciesTableViewCell.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 25/08/2023.
//

import UIKit

class FavoriteCurrenciesTableViewCell: UITableViewCell {

    @IBOutlet weak var currencyFlagImageView: UIImageView!
    @IBOutlet weak var currencyCode: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var checkButton: RadioButton!
    
    var checkbuttonPressed: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        currencyFlagImageView.makeRounded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func checkFavoriteCurrencyButtonPressed(_ sender: UIButton) {
        checkbuttonPressed?()
    }
}
