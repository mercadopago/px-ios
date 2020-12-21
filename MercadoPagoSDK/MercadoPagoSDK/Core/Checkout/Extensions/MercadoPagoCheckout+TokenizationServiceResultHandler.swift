//
//  MercadoPagoCheckout+TokenizationServiceResultHandler.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 12/04/2019.
//

import Foundation

extension MercadoPagoCheckout: TokenizationServiceResultHandler {
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
        viewModel.updateCheckoutModel(token: token)
        executeNextStep()
    }

    func finishWithESCError() {
        executeNextStep()
    }

    func finishWithError(error: MPSDKError, securityCode: String? = nil) {
        // When last VC is PXSecurityCodeViewController we must not call 'errorInputs' function as we dont want to show the error screen.
        // We just clean the token and reset the button showing an error snackbar to the user.
        if let securityCodeVC = viewModel.pxNavigationHandler.navigationController.viewControllers.last as? PXSecurityCodeViewController {
            resetButtonAndCleanToken(securityCodeVC: securityCodeVC)
        } else {
            viewModel.errorInputs(error: error, errorCallback: { [weak self] () in
                self?.getTokenizationService().createCardToken(securityCode: securityCode)
            })
            self.executeNextStep()
        }
    }

    func getTokenizationService(needToShowLoading: Bool = true) -> TokenizationService {
        return TokenizationService(paymentOptionSelected: viewModel.paymentOptionSelected, cardToken: viewModel.cardToken, pxNavigationHandler: viewModel.pxNavigationHandler, needToShowLoading: needToShowLoading, mercadoPagoServices: viewModel.mercadoPagoServices, gatewayFlowResultHandler: self)
    }
}
