//
//  Convert.swift
//  CurrencyConversion
//
//  Created by Hend on 24/08/2023.
//

import UIKit

class Convert: UIView {
    var addToFavoriteButtonPressedHandler: (() -> Void)?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func addToFavoriteButtonPressed(_ sender: UIButton) {
        addToFavoriteButtonPressedHandler?()
    }
}
