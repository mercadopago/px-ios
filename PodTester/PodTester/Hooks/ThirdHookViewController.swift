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
    
    var targetHookStore: PXHookStore?
    
    @IBOutlet weak var hookStoreDebugLabel: UILabel!
    
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
    
    func renderDidFinish() {
        if let savedValue = targetHookStore?.getData(forKey: "key"), let savedValueStr = savedValue as? String  {
            hookStoreDebugLabel.text = savedValueStr.debugDescription
        } else {
            hookStoreDebugLabel.text = "{empty}"
        }
    }
    
    func didReceive(hookStore: PXHookStore) {
        targetHookStore = hookStore
    }
}

//MARK: - Presentation-Navigation
extension ThirdHookViewController {
    static func get() -> ThirdHookViewController {
        return HooksNavigationManager().getThirdHook()
    }
}
