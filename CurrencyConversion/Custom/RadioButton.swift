//
//  RadioButton.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 25/08/2023.

import UIKit

class RadioButton: UIButton {
    var isChecked: Bool = false {
        didSet {
            updateButtonAppearance()
        }
    }
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initButton()
    }
    
    func initButton() {
        self.backgroundColor = .clear
        self.tintColor = .clear
        self.setTitle("", for: .normal)
        updateButtonAppearance()
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped() {
        isChecked = !isChecked
        feedbackGenerator.impactOccurred()
    }
    
    func updateButtonAppearance() {
        if isChecked {
            self.setImage(UIImage(named: "radio_button_checked")?.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            self.setImage(UIImage(named: "radio_button_unchecked")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
}
