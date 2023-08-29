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

        let arabicDigits = "٠١٢٣٤٥٦٧٨٩"
        let englishDigits = "0123456789"
        
        let enteredCharacterSet = CharacterSet(charactersIn: string)
        let containsArabicDigits = enteredCharacterSet.isSubset(of: CharacterSet(charactersIn: arabicDigits))
        
        return !containsArabicDigits
    }
}
