//
//  OneTapFlow+PaymentFlow.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 23/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension OneTapFlow {
    func startPaymentFlow() {
        guard let paymentFlow = model.paymentFlow else {
            return
        }
        paymentFlow.paymentErrorHandler = self
        if model.needToShowLoading() {
            self.pxNavigationHandler.presentLoading()
        }
        paymentFlow.setData(paymentData: model.paymentData, checkoutPreference: model.checkoutPreference, resultHandler: self)
        paymentFlow.start()
    }
}

extension OneTapFlow: PXPaymentResultHandlerProtocol {
    func finishPaymentFlow(error: MPSDKError) {
        trackErrorEvent(error: error)
        guard let reviewScreen = pxNavigationHandler.navigationController.viewControllers.last as? PXOneTapViewController else {
            return
        }
        reviewScreen.resetButton()
    }

    func finishPaymentFlow(paymentResult: PaymentResult, instructionsInfo: PXInstructions?) {
        self.model.paymentResult = paymentResult
        self.model.instructionsInfo = instructionsInfo
        if self.model.needToShowLoading() {
            self.executeNextStep()
        } else {
            PXAnimatedButton.animateButtonWith(status: paymentResult.status, statusDetail: paymentResult.statusDetail)
        }
    }

    func finishPaymentFlow(businessResult: PXBusinessResult) {
        self.model.businessResult = businessResult
        if self.model.needToShowLoading() {
            self.executeNextStep()
        } else {
            PXAnimatedButton.animateButtonWith(status: businessResult.getStatus().getDescription())
        }
    }
}

extension OneTapFlow: PXPaymentErrorHandlerProtocol {
    func escError() {
        model.readyToPay = true
        model.mpESCManager.deleteESC(cardId: model.paymentData.getToken()?.cardId ?? "")
        model.paymentData.cleanToken()
        executeNextStep()
    }
}

// MARK: Tracking
extension OneTapFlow {
    func trackErrorEvent(error: MPSDKError) {
        var properties: [String: Any] = [:]
        properties["path"] = TrackingPaths.Screens.OneTap.getOneTapPath()
        properties["style"] = "snackbar"
        properties["id"] = "px_generic_error"
        properties["message"] = "review_and_confirm_toast_error".localized_beta
        properties["attributable_to"] = "mercadopago"

        var extraDic: [String: Any] = [:]
        extraDic["api_url"] =  error.requestOrigin
        extraDic["retry_available"] = error.retry ?? false

        if let cause = error.apiException?.cause?.first {
            if !String.isNullOrEmpty(cause.code) {
                extraDic["api_status_code"] = cause.code
                extraDic["api_error_message"] = cause.causeDescription
            }
        }

        properties["extra_info"] = extraDic
        MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.getErrorPath(), properties: properties)
    }
}
