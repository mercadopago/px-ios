//
//  PXPluginNavigationHandler.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 12/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPluginNavigationHandler: NSObject {

    private var checkout: MercadoPagoCheckout?

    public init(withCheckout: MercadoPagoCheckout) {
        self.checkout = withCheckout
    }

    open func didFinishPayment(businessResult: PXBusinessResult) {
        self.checkout?.viewModel.businessResult = businessResult
        self.checkout?.executeNextStep()
    }

    open func didFinishPayment(paymentStatus: PXPaymentMethodPlugin.RemotePaymentStatus, statusDetails: String = "", receiptId: String? = nil) {

        guard let paymentData = self.checkout?.viewModel.paymentData else {
            return
        }

        if statusDetails == RejectedStatusDetail.INVALID_ESC {
            checkout?.viewModel.prepareForInvalidPaymentWithESC()
            checkout?.executeNextStep()
            return
        }

        var statusDetailsStr = statusDetails

        // By definition of MVP1, we support only approved or rejected.
        var paymentStatusStrDefault = PaymentStatus.REJECTED
        if paymentStatus == .APPROVED {
            paymentStatusStrDefault = PaymentStatus.APPROVED
        }

        // Set paymentPlugin image into payment method.
        if let paymentMethodPlugin = self.checkout?.viewModel.paymentOptionSelected as? PXPaymentMethodPlugin {
            paymentData.paymentMethod?.setExternalPaymentMethodImage(externalImage: paymentMethodPlugin.getImage())

            // Defaults status details for paymentMethod plugin
            if paymentStatus == .APPROVED {
                statusDetailsStr = ""
            } else {
                statusDetailsStr = RejectedStatusDetail.REJECTED_PLUGIN_PM
            }
        }

        let paymentResult = PaymentResult(status: paymentStatusStrDefault, statusDetail: statusDetailsStr, paymentData: paymentData, payerEmail: nil, id: receiptId, statementDescription: nil)

        checkout?.setPaymentResult(paymentResult: paymentResult)
        checkout?.executeNextStep()
    }

    open func didFinishPayment(status: String, statusDetail: String, receiptId: String? = nil) {

        guard let paymentData = self.checkout?.viewModel.paymentData else {
            return
        }

        if statusDetail == RejectedStatusDetail.INVALID_ESC {
            checkout?.viewModel.prepareForInvalidPaymentWithESC()
            checkout?.executeNextStep()
            return
        }

        if let paymentMethodPlugin = self.checkout?.viewModel.paymentOptionSelected as? PXPaymentMethodPlugin {
            paymentData.paymentMethod?.setExternalPaymentMethodImage(externalImage: paymentMethodPlugin.getImage())
        }

        let paymentResult = PaymentResult(status: status, statusDetail: statusDetail, paymentData: paymentData, payerEmail: nil, id: receiptId, statementDescription: nil)

        checkout?.setPaymentResult(paymentResult: paymentResult)
        checkout?.executeNextStep()
    }

    open func showFailure(message: String, errorDetails: String, retryButtonCallback: (() -> Void)?) {
        MercadoPagoCheckoutViewModel.error = MPSDKError(message: message, errorDetail: errorDetails, retry: retryButtonCallback != nil)
        checkout?.viewModel.errorCallback = retryButtonCallback
        checkout?.executeNextStep()
    }

    open func next() {
        checkout?.executeNextStep()
    }

    open func nextAndRemoveCurrentScreenFromStack() {
        guard let currentViewController = self.checkout?.navigationController.viewControllers.last else {
            checkout?.executeNextStep()
            return
        }

        checkout?.executeNextStep()

        if let indexOfLastViewController = self.checkout?.navigationController.viewControllers.index(of: currentViewController) {
            self.checkout?.navigationController.viewControllers.remove(at: indexOfLastViewController)
        }
    }

    open func cancel() {
        checkout?.cancel()
    }

    open func showLoading() {
        checkout?.presentLoading()
    }

    open func hideLoading() {
        checkout?.dismissLoading()
    }
}
