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
        if lastViewController is PXNewResultViewController || lastViewController is PXSecurityCodeViewController {
            DispatchQueue.main.async {
                if let newResultViewController = lastViewController as? PXNewResultViewController {
                    newResultViewController.progressButtonAnimationTimeOut()
                } else if let securityCodeVC = lastViewController as? PXSecurityCodeViewController {
                    self.resetButtonAndCleanToken(securityCodeVC: securityCodeVC)
                }
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

    func resetButtonAndCleanToken(securityCodeVC: PXSecurityCodeViewController) {
        viewModel.paymentData.cleanToken()
        securityCodeVC.resetButton()
    }

    private func shouldCallAnimateButton() -> Bool {
        let lastViewController = viewModel.pxNavigationHandler.navigationController.viewControllers.last
        if lastViewController is PXNewResultViewController || lastViewController is PXSecurityCodeViewController {
            return true
        }
        return false
    }
}
