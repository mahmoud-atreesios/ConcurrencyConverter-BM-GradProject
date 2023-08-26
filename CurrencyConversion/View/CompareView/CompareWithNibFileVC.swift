//
//  CompareWithNibFileVC.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 25/08/2023.
//

import UIKit

class CompareWithNibFileVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let cornerRadius: CGFloat = 20
            let textFieldHeight: CGFloat = 48
            let borderColor = UIColor(red: 0.773, green: 0.773, blue: 0.773, alpha: 1).cgColor
            let borderWidth: CGFloat = 0.5
            let padding: CGFloat = 15
        
        
        if let customView = Bundle.main.loadNibNamed("Compare", owner: self, options: nil)?.first as? Compare {
            self.view = customView
            
            print("I am in the CompareVC")
            
        }
    }

    @IBAction func compareButtonPressed(_ sender: UIButton) {
        print("compare button pressed")
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

//    func configureDropDown(_ dropDown: DropDown, cornerRadius: CGFloat, height: CGFloat, borderWidth: CGFloat, borderColor: CGColor, padding: CGFloat) {
//        dropDown.layer.masksToBounds = true
//        dropDown.layer.cornerRadius = cornerRadius
//        dropDown.heightAnchor.constraint(equalToConstant: height).isActive = true
//        dropDown.layer.borderWidth = borderWidth
//        dropDown.layer.borderColor = borderColor
//        
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: height))
//        dropDown.leftView = paddingView
//        dropDown.leftViewMode = .always
//    }
    
    
}
