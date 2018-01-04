//
//  PaymentPluginViewController.swift
//  PodTester
//
//  Created by Eden Torres on 12/11/17.
//  Copyright © 2017 AUGUSTO COLLERONE ALFONSO. All rights reserved.
//

import UIKit
import MercadoPagoSDK

class PaymentPluginViewController: UIViewController {

    // MARK: Outlets.
    @IBOutlet weak var loadingView: UIActivityIndicatorView!

    fileprivate var navigationHandler: PXPluginNavigationHandler?

    // MARK: Lifecycle.
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: Plugin implementation.
extension PaymentPluginViewController: PXPluginComponent {

    func render() -> UIView {
        return self.view
    }

    func titleForNavigationBar() -> String? {
        return "Procesando el pago..."
    }

    func renderDidFinish() {
        loadingView.startAnimating()
        perform(#selector(PaymentPluginViewController.fakeFailurePaymentExample), with: nil, afterDelay: 2.0)
    }

    func navigationHandlerForPlugin(navigationHandler: PXPluginNavigationHandler) {
        self.navigationHandler = navigationHandler
    }
}

// MARK: Actions.
extension PaymentPluginViewController {

    func fakeFailurePaymentExample() {
        loadingView.stopAnimating()
        navigationHandler?.showFailure(message: "Opps, algo salio mal", errorDetails: "Error al procesar pago.", retryButtonCallback: {
            self.loadingView.startAnimating()
            self.perform(#selector(PaymentPluginViewController.finishPaymentSuccessExample), with: nil, afterDelay: 4.0)
        })
    }

    func finishPaymentSuccessExample() {
        loadingView.stopAnimating()
        navigationHandler?.didFinishPayment(paymentStatus: .APPROVED)
    }
}
