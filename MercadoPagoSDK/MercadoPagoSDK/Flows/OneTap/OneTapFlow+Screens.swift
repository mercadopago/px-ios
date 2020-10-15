//
//  OneTapFlow+Screens.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 09/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension OneTapFlow {
    func showOneTapViewController() {
        let callbackPaymentData: ((PXPaymentData) -> Void) = { [weak self] (paymentData: PXPaymentData) in
            self?.cancelFlowForNewPaymentSelection()
        }
        let callbackConfirm: ((PXPaymentData, Bool) -> Void) = { [weak self] (paymentData, splitAccountMoneyEnabled) in
            guard let self = self else { return }
            self.model.updateCheckoutModel(paymentData: paymentData, splitAccountMoneyEnabled: splitAccountMoneyEnabled)
            // Deletes default one tap option in payment method search
            self.executeNextStep()
        }
        let callbackUpdatePaymentOption: ((PaymentMethodOption) -> Void) = { [weak self] paymentMethodOption in
            if let cardSliderViewModel = paymentMethodOption as? PXCardSliderViewModel,
               let customerPaymentMethodOption = self?.getCustomerPaymentMethodOption(cardId: cardSliderViewModel.cardId ?? "") {
                // Customer card.
                self?.model.paymentOptionSelected = customerPaymentMethodOption
            } else {
                self?.model.paymentOptionSelected = paymentMethodOption
            }
        }
        let callbackRefreshInit: ((String) -> Void) = { [weak self] cardId in
            self?.refreshInitFlow(cardId: cardId)
        }
        let callbackExit: (() -> Void) = { [weak self] in
            self?.cancelFlow()
        }
        let finishButtonAnimation: (() -> Void) = { [weak self] in
            self?.executeNextStep()
        }
        let viewModel = model.oneTapViewModel()
        model.pxOneTapViewModel = viewModel
        let viewController = PXOneTapViewController(viewModel: viewModel, timeOutPayButton: model.getTimeoutForOneTapReviewController(), callbackPaymentData: callbackPaymentData, callbackConfirm: callbackConfirm, callbackUpdatePaymentOption: callbackUpdatePaymentOption, callbackRefreshInit: callbackRefreshInit, callbackExit: callbackExit, finishButtonAnimation: finishButtonAnimation)

        pxNavigationHandler.pushViewController(viewController: viewController, animated: true)
    }

    func updateOneTapViewModel(cardId: String) {
        if let oneTapViewController = pxNavigationHandler.navigationController.viewControllers.first(where: { $0 is PXOneTapViewController }) as? PXOneTapViewController {
            let viewModel = model.oneTapViewModel()
            oneTapViewController.update(viewModel: viewModel, cardId: cardId)
        }
    }

    func showSecurityCodeScreen() {
        let securityCodeVc = SecurityCodeViewController(viewModel: model.savedCardSecurityCodeViewModel(), collectSecurityCodeCallback: { [weak self] (_, securityCode) in
            self?.getTokenizationService().createCardToken(securityCode: securityCode)
        })
        pxNavigationHandler.pushViewController(viewController: securityCodeVc, animated: true)
    }

    func showKyCScreen() {
        MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.OneTap.getOfflineMethodStartKYCPath())
        PXDeepLinkManager.open(model.getKyCDeepLink())
    }
}
