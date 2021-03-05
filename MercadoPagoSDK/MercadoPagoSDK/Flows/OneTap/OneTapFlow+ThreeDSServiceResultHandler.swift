//
//  OneTapFlow+ThreeDSServiceResultHandler.swift
//  MercadoPagoSDKV4
//
//  Created by Eric Ertl on 05/03/2021.
//

import Foundation

extension OneTapFlow: ThreeDSServiceResultHandler {
    func finishFlow(threeDSAuthorization: Bool) {
        model.updateCheckoutModel(threeDSAuthorization: threeDSAuthorization)
        executeNextStep()
    }
    
    func finishWithError(error: MPSDKError) {
        if isShowingLoading() {
            pxNavigationHandler.showErrorScreen(error: error,
                                                callbackCancel: resultHandler?.exitCheckout,
                                                errorCallback: { [weak self] in
                self?.getThreeDSService().authorize3DS()
            })
        } else {
            finishPaymentFlow(error: error)
        }
    }
    
    func getThreeDSService() -> ThreeDSService {
        let needToShowLoading = isPXSecurityCodeViewControllerLastVC() ? false : model.needToShowLoading()
        return ThreeDSService(paymentData: model.paymentData, oneTap: model.search.oneTap, amountToPay: model.amountHelper.amountToPay, siteId: model.checkoutPreference.siteId, pxNavigationHandler: pxNavigationHandler, needToShowLoading: needToShowLoading, resultHandler: self)
    }
}
