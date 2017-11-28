//
//  PXActionHandler.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 11/28/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class PXActionHandler: NSObject {

    private var checkout: MercadoPagoCheckout?
    private var targetHook: HookStep?

    public init(withCheckout: MercadoPagoCheckout, targetHook: HookStep) {
        self.checkout = withCheckout
        self.targetHook = targetHook
    }

    open func next() {
        if let targetHook = targetHook, targetHook == .AFTER_PAYMENT_TYPE_SELECTED {
            if let paymentOptionSelected = self.checkout?.viewModel.paymentOptionSelected {
                self.checkout?.viewModel.updateCheckoutModel(paymentOptionSelected: paymentOptionSelected)
            }
        }
        checkout?.executeNextStep()
    }

    open func back() {
        checkout?.executePreviousStep()
    }

    open func showLoading() {
        checkout?.presentLoading()
    }

    open func hideLoading() {
        checkout?.dismissLoading()
    }
}
