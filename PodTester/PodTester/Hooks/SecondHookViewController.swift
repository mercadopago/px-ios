//
//  SecondHookViewController.swift
//  PodTester
//
//  Created by Juan sebastian Sanzone on 4/12/17.
//  Copyright © 2017 AUGUSTO COLLERONE ALFONSO. All rights reserved.
//

import UIKit
import MercadoPagoSDK

class SecondHookViewController: UIViewController {
    
    var actionHandler: PXActionHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapOnNext() {
        actionHandler?.next()
    }
}

//MARK: - Hooks implementation.
extension SecondHookViewController: PXHookComponent {
    
    func hookForStep() -> PXHookStep {
        return .AFTER_PAYMENT_METHOD_CONFIG
    }
    
    func render() -> UIView {
        return self.view
    }
    
    func titleForNavigationBar() -> String? {
        return "Hook 2"
    }
}


//MARK: - Presentation-Navigation
extension SecondHookViewController {
    static func get() -> SecondHookViewController {
        return HooksNavigationManager().getSecondHook()
    }
}
