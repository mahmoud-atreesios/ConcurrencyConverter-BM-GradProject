//
//  Extension+UITextField.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 26/08/2023.
//

import Foundation

class NumericInputFilter {
    static func filterInput(_ string: String) -> Bool {
        if string.isEmpty {
            return true
        }

        let allowedCharacterSet = CharacterSet.decimalDigits
        let enteredCharacterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: enteredCharacterSet)
    }
}
