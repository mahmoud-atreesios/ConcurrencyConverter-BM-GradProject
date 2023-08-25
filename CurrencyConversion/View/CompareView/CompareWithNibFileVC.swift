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
        if let customView = Bundle.main.loadNibNamed("Compare", owner: self, options: nil)?.first as? Compare {
            self.view = customView
            
            print("I am in the CompareVC")
            
        }
    }

    @IBAction func compareButtonPressed(_ sender: UIButton) {
        print("compare button pressed")
    }
}
