//
//  UiViewController+Alert.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 28/08/2023.
//

import Foundation
import UIKit
import iOSDropDown

extension UIViewController{
    func show(errorAlert error: NSError) {
        show(error.localizedDescription)
    }
    
    func show(messageAlert title: String, message: String? = "", actionTitle: String? = nil, action: ((UIAlertAction) -> Void)? = nil) {
        show(title, message: message, actionTitle: actionTitle, action: action)
    }
    
    fileprivate func show(_ title: String,  message: String? = "", actionTitle: String? = nil , action: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let _actionTitle = actionTitle {
            alert.addAction(UIAlertAction(title: _actionTitle , style: .default, handler: action))
        }
        
        alert.addAction(UIAlertAction(title:"close" , style: .cancel,  handler: action))
        
        present(alert, animated: true, completion: nil)
    }
    
    func configureTextField(_ textField: UITextField, cornerRadius: CGFloat, height: CGFloat, borderWidth: CGFloat, borderColor: CGColor, padding: CGFloat) {
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = cornerRadius
        textField.heightAnchor.constraint(equalToConstant: height).isActive = true
        textField.layer.borderWidth = borderWidth
        textField.layer.borderColor = borderColor
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    func configureDropDown(_ dropDown: DropDown, cornerRadius: CGFloat, height: CGFloat, borderWidth: CGFloat, borderColor: CGColor, padding: CGFloat) {
        dropDown.layer.masksToBounds = true
        dropDown.layer.cornerRadius = cornerRadius
        dropDown.heightAnchor.constraint(equalToConstant: height).isActive = true
        dropDown.layer.borderWidth = borderWidth
        dropDown.layer.borderColor = borderColor
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: height))
        dropDown.leftView = paddingView
        dropDown.leftViewMode = .always
    }
    
}


