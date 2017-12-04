//
//  ThirdHookViewController.swift
//  PodTester
//
//  Created by Juan sebastian Sanzone on 4/12/17.
//  Copyright © 2017 AUGUSTO COLLERONE ALFONSO. All rights reserved.
//

import UIKit
import MercadoPagoSDK

class ThirdHookViewController: UIViewController {
    
    var actionHandler: PXActionHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapOnNext() {
        actionHandler?.next()
    }
}

//MARK: - Hooks implementation.
extension ThirdHookViewController: PXHookComponent {
    
    func hookForStep() -> PXHookStep {
        return .BEFORE_PAYMENT
    }
    
    func render() -> UIView {
        return self.view
    }
    
    func titleForNavigationBar() -> String? {
        return "Hook 3"
    }
}

//MARK: - Presentation-Navigation
extension ThirdHookViewController {
    static func get() -> ThirdHookViewController {
        return HooksNavigationManager().getThirdHook()
    }
}
