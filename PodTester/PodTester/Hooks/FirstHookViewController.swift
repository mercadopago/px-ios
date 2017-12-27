//
//  FirstHookViewController.swift
//  PodTester
//
//  Created by Juan sebastian Sanzone on 4/12/17.
//  Copyright © 2017 AUGUSTO COLLERONE ALFONSO. All rights reserved.
//

import UIKit
import MercadoPagoSDK

class FirstHookViewController: UIViewController {

    fileprivate var navigationHandler: PXHookNavigationHandler?
    
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNextButton()
    }
}

//MARK: - Hooks implementation.
extension FirstHookViewController: PXHookComponent {
    
    func hookForStep() -> PXHookStep {
        return .BEFORE_PAYMENT_METHOD_CONFIG
    }
    
    func render() -> UIView {
        return self.view
    }
    
    func shouldSkipHook(hookStore: PXCheckoutStore) -> Bool {
        if let paymentId = hookStore.getPaymentOptionSelected()?.getId(), paymentId == "bitcoin_payment" {
            return true
        }
        return false
    }
    
    func renderDidFinish() {
        messageLabel.text = nil
        passwordTextfield.text = nil
        passwordTextfield.becomeFirstResponder()
    }
    
    func titleForNavigationBar() -> String? {
        return "Hook 1"
    }

    func navigationHandlerForHook(navigationHandler: PXHookNavigationHandler) {
        self.navigationHandler = navigationHandler
    }
}

//MARK: - Setup methods.
extension FirstHookViewController {
 
    fileprivate func setupNextButton() {
        let nextButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 55.0))
        nextButton.backgroundColor = UIColor.mpDefaultColor()
        nextButton.tintColor = UIColor.white
        nextButton.setTitle("Continuar", for: .normal)
        nextButton.addTarget(self, action: #selector(FirstHookViewController.shouldNextAction), for: .touchUpInside)
        passwordTextfield.inputAccessoryView = nextButton
    }
    
    func shouldNextAction() {
        if let text = passwordTextfield.text, !text.isEmpty {
            navigationHandler?.next()
        } else {
            messageLabel.text = "Debes completar este campo."
        }
    }
}

//MARK: - Presentation-Navigation
extension FirstHookViewController {
    static func get() -> FirstHookViewController {
        return HooksNavigationManager().getFirstHook()
    }
}
