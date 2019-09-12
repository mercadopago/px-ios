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
        let reviewVC = PXOneTapViewController(viewModel: model.reviewConfirmViewModel(), timeOutPayButton: model.getTimeoutForOneTapReviewController(), callbackPaymentData: { [weak self] (paymentData: PXPaymentData) in
            self?.cancelFlowForNewPaymentSelection()
            return
            }, callbackConfirm: { [weak self] (paymentData: PXPaymentData, splitAccountMoneyEnabled: Bool) in
                self?.model.updateCheckoutModel(paymentData: paymentData, splitAccountMoneyEnabled: splitAccountMoneyEnabled)
                // Deletes default one tap option in payment method search
                self?.executeNextStep()
            }, callbackUpdatePaymentOption: { [weak self] (newPaymentOption: PaymentMethodOption) in
                if let card = newPaymentOption as? PXCardSliderViewModel, let newPaymentOptionSelected = self?.getCustomerPaymentOption(forId: card.cardId ?? "") {
                    // Customer card.
                    self?.model.paymentOptionSelected = newPaymentOptionSelected
                } else if newPaymentOption.getId() == PXPaymentTypes.ACCOUNT_MONEY.rawValue ||
                    newPaymentOption.getId() == PXPaymentTypes.CONSUMER_CREDITS.rawValue {
                    //AM
                    self?.model.paymentOptionSelected = newPaymentOption
                }
            }, callbackExit: { [weak self] in
                self?.cancelFlow()
            }, finishButtonAnimation: { [weak self] in
                self?.executeNextStep()
        })

        pxNavigationHandler.pushViewController(viewController: reviewVC, animated: true)
    }

    func showSecurityCodeScreen() {
        let securityCodeVc = SecurityCodeViewController(viewModel: model.savedCardSecurityCodeViewModel(), collectSecurityCodeCallback: { [weak self] (_, securityCode: String) -> Void in
            self?.getTokenizationService().createCardToken(securityCode: securityCode)
        })
        pxNavigationHandler.pushViewController(viewController: securityCodeVc, animated: true)
    }
}
