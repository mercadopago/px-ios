//
//  MercadoPagoCheckout+PaymentFlowHandler.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 03/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension MercadoPagoCheckout: PXPaymentResultHandlerProtocol {

    func finishPaymentFlow(error: MPSDKError) {
        let lastViewController = viewModel.pxNavigationHandler.navigationController.viewControllers.last
        if lastViewController is PXReviewViewController || lastViewController is PXNewResultViewController {
            if let reviewViewController = lastViewController as? PXReviewViewController {
                reviewViewController.resetButton()
            } else if let newResultViewController = lastViewController as? PXNewResultViewController {
                newResultViewController.progressButtonAnimationTimeOut()
            }
        }
    }

    func finishPaymentFlow(paymentResult: PaymentResult, instructionsInfo: PXInstructions?, pointsAndDiscounts: PXPointsAndDiscounts?) {
        viewModel.remedy = nil
        viewModel.paymentResult = paymentResult
        viewModel.instructionsInfo = instructionsInfo
        viewModel.pointsAndDiscounts = pointsAndDiscounts

        if shouldCallAnimateButton() {
            PXAnimatedButton.animateButtonWith(status: paymentResult.status, statusDetail: paymentResult.statusDetail)
        } else {
            executeNextStep()
        }
    }

    func finishPaymentFlow(businessResult: PXBusinessResult, pointsAndDiscounts: PXPointsAndDiscounts?) {
        viewModel.remedy = nil
        viewModel.businessResult = businessResult
        viewModel.pointsAndDiscounts = pointsAndDiscounts

        if shouldCallAnimateButton() {
            PXAnimatedButton.animateButtonWith(status: businessResult.getBusinessStatus().getDescription())
        } else {
            executeNextStep()
        }
    }

    private func shouldCallAnimateButton() -> Bool {
        let lastViewController = viewModel.pxNavigationHandler.navigationController.viewControllers.last
        if lastViewController is PXReviewViewController || lastViewController is PXNewResultViewController {
            return true
        }
        return false
    }
}
