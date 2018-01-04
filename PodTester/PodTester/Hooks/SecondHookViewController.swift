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

    fileprivate var navigationHandler: PXHookNavigationHandler?

    var targetHookStore: PXCheckoutStore?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didTapOnNext() {
        navigationHandler?.next()
    }

    @IBAction func didTapOnloadingExample() {
        navigationHandler?.showLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.navigationHandler?.hideLoading()
        })
    }

    @IBAction func didTapOnSetData() {

        let alert = UIAlertController(title: "Hook Store", message: "Ingrese valor para grabar en HookStore", preferredStyle: UIAlertControllerStyle.alert)

        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = ""
        })

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction: UIAlertAction!) in
            if let textField = alert.textFields?.first, let targetText = textField.text {
               self.targetHookStore?.addData(forKey: "key", value: targetText)
            }
        }))

        present(alert, animated: true, completion: nil)
    }

}

// MARK: - Hooks implementation.
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

    func didReceive(hookStore: PXCheckoutStore) {
        targetHookStore = hookStore
    }

    func shouldSkipHook(hookStore: PXCheckoutStore) -> Bool {
        if let paymentId = hookStore.getPaymentOptionSelected()?.getId(), paymentId == "bitcoin_payment" {
            return true
        }
        return false
    }

    func navigationHandlerForHook(navigationHandler: PXHookNavigationHandler) {
        self.navigationHandler = navigationHandler
    }
}

// MARK: - Presentation-Navigation
extension SecondHookViewController {
    static func get() -> SecondHookViewController {
        return HooksNavigationManager().getSecondHook()
    }
}
