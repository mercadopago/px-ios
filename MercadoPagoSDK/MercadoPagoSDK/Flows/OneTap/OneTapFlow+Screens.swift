//
//  OneTapFlow+Screens.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 09/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension OneTapFlow {
    func showReviewAndConfirmScreenForOneTap() {
        let callbackPaymentData: ((PXPaymentData) -> Void) = {
            [weak self] (paymentData: PXPaymentData) in
            self?.cancelFlowForNewPaymentSelection()
        }
        let callbackConfirm: ((PXPaymentData, Bool) -> Void) = {
            [weak self] (paymentData: PXPaymentData, splitAccountMoneyEnabled: Bool) in
            self?.model.updateCheckoutModel(paymentData: paymentData, splitAccountMoneyEnabled: splitAccountMoneyEnabled)
            // Deletes default one tap option in payment method search
            self?.executeNextStep()
        }
        let callbackUpdatePaymentOption: ((PaymentMethodOption) -> Void) = {
            [weak self] (newPaymentOption: PaymentMethodOption) in
            if let card = newPaymentOption as? PXCardSliderViewModel, let newPaymentOptionSelected = self?.getCustomerPaymentOption(forId: card.cardId ?? "") {
                // Customer card.
                self?.model.paymentOptionSelected = newPaymentOptionSelected
            } else if newPaymentOption.getId() == PXPaymentTypes.ACCOUNT_MONEY.rawValue ||
                newPaymentOption.getId() == PXPaymentTypes.CONSUMER_CREDITS.rawValue {
                // AM
                self?.model.paymentOptionSelected = newPaymentOption
            }
        }
        let callbackExit: (() -> Void) = {
            [weak self] in
            self?.cancelFlow()
        }
        let finishButtonAnimation: (() -> Void) = {
            //[weak self] in
            // WARNING: Keep strong ref here (or any other block for this initializer) or it'll release the object after creating it
            self.executeNextStep()
        }
        let viewModel = model.reviewConfirmViewModel()
        
        let reviewVC = PXOneTapViewController(viewModel: viewModel, timeOutPayButton: model.getTimeoutForOneTapReviewController(), callbackPaymentData: callbackPaymentData, callbackConfirm: callbackConfirm, callbackUpdatePaymentOption: callbackUpdatePaymentOption, callbackExit: callbackExit, finishButtonAnimation: finishButtonAnimation)

        pxNavigationHandler.pushViewController(viewController: reviewVC, animated: true)
    }

    func showSecurityCodeScreen() {
        let securityCodeVc = SecurityCodeViewController(viewModel: model.savedCardSecurityCodeViewModel(), collectSecurityCodeCallback: { [weak self] (_, securityCode: String) -> Void in
            self?.getTokenizationService().createCardToken(securityCode: securityCode)
        })
        pxNavigationHandler.pushViewController(viewController: securityCodeVc, animated: true)
    }
}
