//
//  MercadoPagoCheckoutViewModel + Hooks.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 11/28/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
extension MercadoPagoCheckoutViewModel {

    func shouldShowHook(hookStep: PXHookStep) -> Bool {
        
        guard let hookSelected = MercadoPagoCheckoutViewModel.flowPreference.getHookForStep(hookStep: hookStep) else {
            return false
        }

        copyViewModelAndAssignToHookStore()
        
        if let shouldSkip = hookSelected.shouldSkipHook?(hookStore: PXHookStore.sharedInstance), shouldSkip {
            self.continueFrom(hook: hookSelected.hookForStep())
            return false
        }

        switch hookStep {
        case .AFTER_PAYMENT_TYPE_SELECTED:
            return shouldShowHook1()
        case .AFTER_PAYMENT_METHOD_SELECTED:
            return shouldShowHook2()
        case .BEFORE_PAYMENT:
            return shouldShowHook3()
        }
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
    func copyViewModelAndAssignToHookStore() -> Bool {
        // Set a copy of CheckoutVM in HookStore
        if self.copy() is MercadoPagoCheckoutViewModel {
            PXHookStore.sharedInstance.paymentData = self.paymentData
            PXHookStore.sharedInstance.paymentOptionSelected = self.paymentOptionSelected
            return true
        }
        return false
    }
}
