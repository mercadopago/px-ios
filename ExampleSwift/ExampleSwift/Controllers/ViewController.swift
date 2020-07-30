//
//  ViewController.swift
//  ExampleSwift
//
//  Created by Juan sebastian Sanzone on 11/9/18.
//  Copyright © 2018 Juan Sebastian Sanzone. All rights reserved.
// Check full documentation: http://mercadopago.github.io/px-ios/v4/
//

import UIKit

#if PX_PRIVATE_POD
    import MercadoPagoSDKV4
#else
    import MercadoPagoSDK
#endif

// Check full documentation: http://mercadopago.github.io/px-ios/v4/
class ViewController: UIViewController {
    private var checkout: MercadoPagoCheckout?
    
    @IBAction func initDefault(_ sender: Any) {
        // runMercadoPagoCheckout()
        runMercadoPagoCheckoutWithLifecycle()
    }
    
    @IBAction func launchCongrats(_ sender: Any) {
        guard let navController = navigationController else { return }
        _ = PXPaymentCongrats()
            .withStatus(.APPROVED)
            .withHeaderTitle("¡Listo! Ya le pagaste a SuperMarket")
            .withHeaderImage(nil, orURL: "https://mla-s2-p.mlstatic.com/600619-MLA32239048138_092019-O.jpg")
            .withHeaderCloseAction {
                navController.popViewController(animated: true)
        }
            .shouldShowReceipt(true, receiptId: "123")
            .withMainAction(label: "Continuar", action: {
                navController.popViewController(animated: true)
            })
            .withSecondaryAction(label: "Tuve un problema", action: {
                navController.popViewController(animated: true)
            })
            .withPointsData(percentage: 0.85, levelColor: "#4063EA", levelNumber: 4, title: "Ud ganó 2.000 puntos", actionLabel: "Ver mis beneficios", actionTarget: "meli://loyalty/webview?url=https%3A%2F%2Fwww.mercadolivre.com.br%2Fmercado-pontos%2Fv2%2Fhub%23origin%3Dcongrats")
            .withDiscountsData()
            .withCrossSellingData()
            .withExpenseSplit("Expense", backgroundColor: "#000000", textColor: "#FFFFFF", weight: nil, actionLabel: "Action expense", actionTarget: nil, imageURL: "https://mla-s2-p.mlstatic.com/600619-MLA32239048138_092019-O.jpg")
            .withPaymentMethodInfo(PXPaymentInfo(amount: "$ 4321,98", paymentMethodName: "Mastercard", paymentMethodLastFourDigits: "6666", paymentMethodExtraInfo: "70% de descuento", paymentMethodId: "visa", paymentMethodType: PXPaymentTypes.CREDIT_CARD))
            .start(using: navController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        let col1 = UIColor(red: 34.0/255.0, green: 211/255.0, blue: 198/255.0, alpha: 1)
        let col2 = UIColor(red: 145/255.0, green: 72.0/255.0, blue: 203/255.0, alpha: 1)
        gradient.colors = [col1.cgColor, col2.cgColor]
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func runMercadoPagoCheckout() {
        // 1) Create Builder with your publicKey and preferenceId.
        let builder = MercadoPagoCheckoutBuilder(publicKey: "TEST-4763b824-93d7-4ca2-a7f7-93539c3ee5bd", preferenceId: "243966003-0812580b-6082-4104-9bce-1a4c48a5bc44").setLanguage("es")

        // 2) Create Checkout reference
        checkout = MercadoPagoCheckout(builder: builder)

        // 3) Start with your navigation controller.
        if let myNavigationController = navigationController {
            checkout?.start(navigationController: myNavigationController)
        }
    }

    private func runMercadoPagoCheckoutWithLifecycle() {
        // 1) Create Builder with your publicKey and preferenceId.
        let builder = MercadoPagoCheckoutBuilder(publicKey: "TEST-4763b824-93d7-4ca2-a7f7-93539c3ee5bd", preferenceId: "243966003-0812580b-6082-4104-9bce-1a4c48a5bc44").setLanguage("es")

        // 2) Create Checkout reference
        checkout = MercadoPagoCheckout(builder: builder)

        // 3) Start with your navigation controller.
        if let myNavigationController = navigationController {
            checkout?.start(navigationController: myNavigationController, lifeCycleProtocol: self)
        }
    }
}

// MARK: Optional Lifecycle protocol implementation example.
extension ViewController: PXLifeCycleProtocol {
    func finishCheckout() -> ((PXResult?) -> Void)? {
        return nil
    }

    func cancelCheckout() -> (() -> Void)? {
        return nil
    }

    func changePaymentMethodTapped() -> (() -> Void)? {
        return { () in
            print("px - changePaymentMethodTapped")
        }
    }
}
