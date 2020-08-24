//
//  MercadoPagoCheckout+TokenizationServiceResultHandler.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 12/04/2019.
//

import Foundation

extension MercadoPagoCheckout: TokenizationServiceResultHandler {
    func finishInvalidIdentificationNumber() {
        if let identificationViewController = viewModel.pxNavigationHandler.navigationController.viewControllers.last as? IdentificationViewController {
            identificationViewController.showErrorMessage("invalid_field".localized)
        }
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
        viewModel.errorInputs(error: error, errorCallback: { [weak self] () in
            self?.getTokenizationService().createCardToken(securityCode: securityCode)
        })
        self.executeNextStep()
    }

    func getTokenizationService(needToShowLoading: Bool = true) -> TokenizationService {
        return TokenizationService(paymentOptionSelected: viewModel.paymentOptionSelected, cardToken: viewModel.cardToken, pxNavigationHandler: viewModel.pxNavigationHandler, needToShowLoading: needToShowLoading, mercadoPagoServices: viewModel.mercadoPagoServices, gatewayFlowResultHandler: self)
    }
}
