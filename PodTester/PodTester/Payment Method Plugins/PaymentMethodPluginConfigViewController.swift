//
//  PaymentMethodPluginConfigViewController.swift
//  PodTester
//
//  Created by Eden Torres on 12/12/17.
//  Copyright © 2017 AUGUSTO COLLERONE ALFONSO. All rights reserved.
//

import UIKit
import MercadoPagoSDK

class PaymentMethodPluginConfigViewController: UIViewController {

    fileprivate var navigationHandler: PXPluginNavigationHandler?

    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var messageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNextButton()
    }
}

// MARK: - Setup methods.
extension PaymentMethodPluginConfigViewController {

    fileprivate func setupNextButton() {
        let nextButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 55.0))
        nextButton.backgroundColor = UIColor.mpDefaultColor()
        nextButton.tintColor = UIColor.white
        nextButton.setTitle("Continuar", for: .normal)
        nextButton.addTarget(self, action: #selector(PaymentMethodPluginConfigViewController.shouldNextAction), for: .touchUpInside)
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

// MARK: Plugin implementation.
extension PaymentMethodPluginConfigViewController: PXPluginComponent {

    func render() -> UIView {
        return self.view
    }

    func renderDidFinish() {
        messageLabel.text = nil
        passwordTextfield.text = nil
        passwordTextfield.becomeFirstResponder()
    }

    func titleForNavigationBar() -> String? {
        return "Pagar con Bitcoin"
    }

    func navigationHandlerForPlugin(navigationHandler: PXPluginNavigationHandler) {
        self.navigationHandler = navigationHandler
    }
}
