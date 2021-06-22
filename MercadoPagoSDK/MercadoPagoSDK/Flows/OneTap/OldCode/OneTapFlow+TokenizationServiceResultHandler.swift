//
//  OneTapFlow+TokenizationServiceResultHandler.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 09/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension OneTapFlow: TokenizationServiceResultHandler {
    func finishInvalidIdentificationNumber() {
    }

    func finishFlow(token: PXToken, shouldResetESC: Bool) {
        if shouldResetESC {
            getTokenizationService().resetESCCap(cardId: token.cardId) { [weak self] in
                self?.flowCompletion(token: token)
            }
        } else {
            flowCompletion(token: token)
        }
    }

    func flowCompletion(token: PXToken) {
        model.updateCheckoutModel(token: token)
        executeNextStep()
    }

    func finishWithESCError() {
        if let securityCodeVC = pxNavigationHandler.navigationController.viewControllers.last as? PXSecurityCodeViewController {
            // there is no need to clean the token as it could not be created
            securityCodeVC.resetButton()
        } else {
            executeNextStep()
        }
    }

    func finishWithError(error: MPSDKError, securityCode: String? = nil) {
        if isShowingLoading() {
            pxNavigationHandler.showErrorScreen(error: error, callbackCancel: resultHandler?.exitCheckout, errorCallback: { [weak self] () in
                self?.getTokenizationService().createCardToken(securityCode: securityCode)
            })
        } else {
            finishPaymentFlow(error: error)
        }
    }

    func getTokenizationService() -> TokenizationService {
        let needToShowLoading = isPXSecurityCodeViewControllerLastVC() ? false : model.needToShowLoading()
        return TokenizationService(paymentOptionSelected: model.paymentOptionSelected, cardToken: nil, pxNavigationHandler: pxNavigationHandler, needToShowLoading: needToShowLoading, mercadoPagoServices: model.mercadoPagoServices, gatewayFlowResultHandler: self)
    }
}
