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
        let reviewVC = PXOneTapViewController(viewModel: model.reviewConfirmViewModel(), timeOutPayButton: model.getTimeoutForOneTapReviewController(), shouldAnimatePayButton: !model.needToShowLoading(), callbackPaymentData: { [weak self] (paymentData: PXPaymentData) in
            self?.cancelFlowForNewPaymentSelection()
            return
            }, callbackConfirm: {(paymentData: PXPaymentData) in
                self.model.updateCheckoutModel(paymentData: paymentData)

                // Deletes default one tap option in payment method search
                self.executeNextStep()
        }, callbackUpdatePaymentOption: { [weak self] (newPaymentOption: PaymentMethodOption) in
            if let newPaymentOptionSelected = self?.getCustomerPaymentOption(forId: newPaymentOption.getId()) {
                // Customer card.
                self?.model.paymentOptionSelected = newPaymentOptionSelected
            } else {
                // AM
                if newPaymentOption.getId() == PXPaymentTypes.ACCOUNT_MONEY.rawValue {
                    self?.model.paymentOptionSelected = newPaymentOption
                }
            }
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
        let securityCodeVc = SecurityCodeViewController(viewModel: model.savedCardSecurityCodeViewModel(), collectSecurityCodeCallback: { [weak self] (cardInformation: PXCardInformationForm, securityCode: String) -> Void in
            self?.createCardToken(cardInformation: cardInformation as? PXCardInformation, securityCode: securityCode)
        })
        self.pxNavigationHandler.pushViewController(viewController: securityCodeVc, animated: true)
    }
}
