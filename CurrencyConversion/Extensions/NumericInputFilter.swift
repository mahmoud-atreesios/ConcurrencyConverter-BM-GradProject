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

        let englishDigits = "0123456789"

        let enteredCharacterSet = CharacterSet(charactersIn: string)
        let containsEnglishDigits = enteredCharacterSet.isSubset(of: CharacterSet(charactersIn: englishDigits))

        return containsEnglishDigits
    }
}
