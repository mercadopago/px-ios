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
        model.invalidESCReason = nil
        paymentFlow.paymentErrorHandler = self
        if isShowingLoading() {
            pxNavigationHandler.presentLoading()
        }
        paymentFlow.setData(amountHelper: model.amountHelper, checkoutPreference: model.checkoutPreference, resultHandler: self)
        paymentFlow.start()
    }

    func isShowingLoading() -> Bool {
        return pxNavigationHandler.isLoadingPresented() || pxNavigationHandler.isShowingDynamicViewController()
    }

    private func finishPaymentFlow(status: String, statusDetail: String? = nil) {
        if isShowingLoading() {
            executeNextStep()
        } else {
            PXAnimatedButton.animateButtonWith(status: status, statusDetail: statusDetail)
        }
    }
}

extension OneTapFlow: PXPaymentResultHandlerProtocol {
    func finishPaymentFlow(error: MPSDKError) {
        guard let reviewScreen = pxNavigationHandler.navigationController.viewControllers.last as? PXOneTapViewController else {
            return
        }
        reviewScreen.resetButton(error: error)
    }

    func finishPaymentFlow(paymentResult: PaymentResult, instructionsInfo: PXInstructions?, pointsAndDiscounts: PXPointsAndDiscounts?) {
        model.paymentResult = paymentResult
        model.instructionsInfo = instructionsInfo
        model.pointsAndDiscounts = pointsAndDiscounts
        finishPaymentFlow(status: paymentResult.status, statusDetail: paymentResult.statusDetail)
    }

    func finishPaymentFlow(businessResult: PXBusinessResult, pointsAndDiscounts: PXPointsAndDiscounts?) {
        model.businessResult = businessResult
        model.pointsAndDiscounts = pointsAndDiscounts
        finishPaymentFlow(status: businessResult.getBusinessStatus().getDescription())
    }
}

extension OneTapFlow: PXPaymentErrorHandlerProtocol {
    func escError(reason: PXESCDeleteReason) {
        model.readyToPay = true
        model.invalidESCReason = reason
        if let token = model.paymentData.getToken() {
            model.escManager?.deleteESC(token: token, reason: reason, detail: nil)
        }
        model.paymentData.cleanToken()
        executeNextStep()
    }
}
