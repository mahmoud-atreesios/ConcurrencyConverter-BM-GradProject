//
//  ViewController.swift
//  CurrencyConversion
//
//  Created by Mahmoud Mohamed Atrees on 22/08/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage

class ParentVC: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerViewForConvertAndCompare: UIView!
    
    var firstVC = ConvertWithNibFileVC(nibName: "Convert", bundle: nil)
    var secondVC = CompareWithNibFileVC(nibName: "Compare", bundle: nil)
    
    var viewModel = ConvertViewModel()
    let disposeBag = DisposeBag()
    let convertButtonPressed = PublishSubject<Void>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(firstVC)
        addChild(secondVC)
        
        firstVC.view.frame = containerViewForConvertAndCompare.bounds
        secondVC.view.frame = containerViewForConvertAndCompare.bounds
        
        containerViewForConvertAndCompare.addSubview(firstVC.view)
        containerViewForConvertAndCompare.addSubview(secondVC.view)
        
        firstVC.didMove(toParent: self)
        secondVC.didMove(toParent: self)
        
        showViewController(firstVC)
        
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            showViewController(firstVC)
        case 1:
            showViewController(secondVC)
        default:
            break
        }
    }
    
    private func showViewController(_ viewControllerToShow: UIViewController) {
        for vc in children {
            vc.view.isHidden = true
        }
            viewControllerToShow.view.isHidden = false
    }
    
}

