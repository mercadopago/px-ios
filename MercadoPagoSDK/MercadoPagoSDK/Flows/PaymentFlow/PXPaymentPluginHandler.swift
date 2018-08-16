//
//  PXPaymentPluginHandler.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 17/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

/** :nodoc: */
@objcMembers
open class PXPaymentPluginNavigationHandler: NSObject {
    private var flow: PXPaymentFlow?

    internal init(flow: PXPaymentFlow) {
        self.flow = flow
    }

    open func didFinishPayment(businessResult: PXBusinessResult) {
        self.flow?.model.businessResult = businessResult
        self.flow?.executeNextStep()
    }

    open func didFinishPayment(paymentStatus: PXPaymentMethodPlugin.RemotePaymentStatus, statusDetails: String = "", receiptId: String? = nil) {

        guard let paymentData = self.flow?.model.paymentData else {
            return
        }

        if statusDetails == RejectedStatusDetail.INVALID_ESC {
            flow?.paymentErrorHandler?.escError()
            return
        }

        var statusDetailsStr = statusDetails

        // By definition of MVP1, we support only approved or rejected.
        var paymentStatusStrDefault = PaymentStatus.REJECTED
        if paymentStatus == .APPROVED {
            paymentStatusStrDefault = PaymentStatus.APPROVED
        }

        // Set paymentPlugin image into payment method.
        if self.flow?.model.paymentData?.paymentMethod?.paymentTypeId == PaymentTypeId.PAYMENT_METHOD_PLUGIN.rawValue {

            // Defaults status details for paymentMethod plugin
            if paymentStatus == .APPROVED {
                statusDetailsStr = ""
            } else {
                statusDetailsStr = RejectedStatusDetail.REJECTED_PLUGIN_PM
            }
        }

        let paymentResult = PaymentResult(status: paymentStatusStrDefault, statusDetail: statusDetailsStr, paymentData: paymentData, payerEmail: nil, paymentId: receiptId, statementDescription: nil)

        flow?.model.paymentResult = paymentResult
        flow?.executeNextStep()
    }

    open func didFinishPayment(status: String, statusDetail: String, receiptId: String? = nil) {

        guard let paymentData = self.flow?.model.paymentData else {
            return
        }

        if statusDetail == RejectedStatusDetail.INVALID_ESC {
            flow?.paymentErrorHandler?.escError()
            return
        }

        let paymentResult = PaymentResult(status: status, statusDetail: statusDetail, paymentData: paymentData, payerEmail: nil, paymentId: receiptId, statementDescription: nil)

        flow?.model.paymentResult = paymentResult
        flow?.executeNextStep()
    }

    open func next() {
        flow?.executeNextStep()
    }

    open func nextAndRemoveCurrentScreenFromStack() {
        guard let currentViewController = self.flow?.pxNavigationHandler.navigationController.viewControllers.last else {
            flow?.executeNextStep()
            return
        }

        flow?.executeNextStep()

        if let indexOfLastViewController = self.flow?.pxNavigationHandler.navigationController.viewControllers.index(of: currentViewController) {
            self.flow?.pxNavigationHandler.navigationController.viewControllers.remove(at: indexOfLastViewController)
        }
    }

    open func showLoading() {
        flow?.pxNavigationHandler.presentLoading()
    }

    open func hideLoading() {
        flow?.pxNavigationHandler.dismissLoading()
    }
}
