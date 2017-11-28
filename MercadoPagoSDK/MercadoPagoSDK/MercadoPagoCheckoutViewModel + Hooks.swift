//
//  MercadoPagoCheckoutViewModel + Hooks.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 11/28/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
extension MercadoPagoCheckoutViewModel {
    func shouldShowHook(hookStep: HookStep) -> Bool {
        if let _ = MercadoPagoCheckoutViewModel.flowPreference.getHookForStep(hookStep: hookStep) {
            switch hookStep {
            case .AFTER_PAYMENT_TYPE_SELECTED:
                return shouldShowHook1()
            case .AFTER_PAYMENT_METHOD_SELECTED:
                return shouldShowHook2()
            case .BEFORE_PAYMENT:
                return shouldShowHook3()
            }
        }
        return false
    }

    func shouldShowHook1() -> Bool {
        return paymentOptionSelected != nil
    }

    func shouldShowHook2() -> Bool {
        guard let pm = self.paymentData.getPaymentMethod() else {
            return false
        }

        if pm.isCreditCard && !(paymentData.hasPayerCost() && paymentData.hasToken()) {
            return false
        }

        if (pm.isDebitCard || pm.isPrepaidCard) && !paymentData.hasToken() {
            return false
        }

        if pm.isPayerInfoRequired && paymentData.getPayer().identification == nil {
            return false
        }
        return true
    }

    func shouldShowHook3() -> Bool {
        return readyToPay
    }
}
