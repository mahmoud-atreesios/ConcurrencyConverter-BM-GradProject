//
//  AddToFavoritesVC.swift
//  CurrencyConversion
//
//  Created by Hend on 25/08/2023.
//

import UIKit

class AddToFavoritesVC: UIViewController {
    @IBOutlet weak var favoritesContainerUIView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoritesContainerUIView.layer.cornerRadius = 25
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
