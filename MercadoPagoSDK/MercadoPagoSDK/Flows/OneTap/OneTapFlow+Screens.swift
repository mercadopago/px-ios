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
        let reviewVC = PXOneTapViewController(viewModel: model.reviewConfirmViewModel(), timeOutPayButton: model.getTimeoutForOneTapReviewController(), shouldAnimatePayButton: !model.needToShowLoading(), callbackPaymentData: { [weak self] (paymentData: PaymentData) in
            self?.cancelFlow()
            return
            }, callbackConfirm: {(paymentData: PaymentData) in
                self.model.updateCheckoutModel(paymentData: paymentData)

                // Deletes default one tap option in payment method search
                self.executeNextStep()

        }, callbackExit: { [weak self] () -> Void in
            guard let strongSelf = self else {
                return
            }
            strongSelf.cancelFlow()
            }, finishButtonAnimation: {
                self.executeNextStep()
        })

        self.pxNavigationHandler.pushViewController(viewController: reviewVC, animated: true)
    }

    func showSecurityCodeScreen() {
        let securityCodeVc = SecurityCodeViewController(viewModel: model.savedCardSecurityCodeViewModel(), collectSecurityCodeCallback: { [weak self] (cardInformation: CardInformationForm, securityCode: String) -> Void in
            self?.createCardToken(cardInformation: cardInformation as? CardInformation, securityCode: securityCode)
        })
        self.pxNavigationHandler.pushViewController(viewController: securityCodeVc, animated: true)
    }
}
