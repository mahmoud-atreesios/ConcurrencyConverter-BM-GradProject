//
//  Extension+UITextField.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 26/08/2023.
//

import Foundation
import UIKit

extension UITextField {
    func addLeftPadding( padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
    }

    func addRightPadding( padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: frame.height))
        rightView = paddingView
        rightViewMode = .always
    }
}
