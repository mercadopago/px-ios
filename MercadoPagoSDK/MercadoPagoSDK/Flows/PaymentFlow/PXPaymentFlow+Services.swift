//
//  PXPaymentFlow+Services.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 16/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

internal extension PXPaymentFlow {
    func createPaymentWithPlugin(plugin: PXSplitPaymentProcessor?) {
        guard let plugin = plugin else {
            return
        }

        plugin.didReceive?(checkoutStore: PXCheckoutStore.sharedInstance)

        plugin.startPayment?(checkoutStore: PXCheckoutStore.sharedInstance, errorHandler: self as PXPaymentProcessorErrorHandler, successWithBasePayment: { [weak self] (basePayment) in
            self?.handlePayment(basePayment: basePayment)
        })
    }

    func createPayment() {
        guard let _ = model.amountHelper?.getPaymentData(), let _ = model.checkoutPreference else {
            return
        }

        model.assignToCheckoutStore()
        guard let paymentBody = (try? JSONEncoder().encode(PXCheckoutStore.sharedInstance)) else {
            fatalError("Cannot make payment json body")
        }

        var headers: [String: String] = [:]
        if let productId = model.productId {
            headers[MercadoPagoService.HeaderField.productId.rawValue] = productId
        }

        headers[MercadoPagoService.HeaderField.idempotencyKey.rawValue] =  model.generateIdempotecyKey()

        model.mercadoPagoServices.createPayment(url: PXServicesURLConfigs.MP_API_BASE_URL, uri: PXServicesURLConfigs.MP_PAYMENTS_URI, paymentDataJSON: paymentBody, query: nil, headers: headers, callback: { (payment) in
            self.handlePayment(payment: payment)

        }, failure: { [weak self] (error) in

            let mpError = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_PAYMENT.rawValue)

            guard let apiException = mpError.apiException else {
                self?.showError(error: mpError)
                return
            }

            // ESC Errors
            if apiException.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_ESC.rawValue) {
                self?.paymentErrorHandler?.escError(reason: .INVALID_ESC)
            } else if apiException.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_FINGERPRINT.rawValue) {
                self?.paymentErrorHandler?.escError(reason: .INVALID_FINGERPRINT)
            } else if apiException.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_PAYMENT_WITH_ESC.rawValue) {
                self?.paymentErrorHandler?.escError(reason: .ESC_CAP)
            } else if apiException.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_PAYMENT_IDENTIFICATION_NUMBER.rawValue) {
                self?.paymentErrorHandler?.identificationError?()
            } else {
                self?.showError(error: mpError)
            }
        })
    }

    func getPointsAndDiscounts() {

        var paymentIds = [String]()
        if let paymentResultId = model.paymentResult?.paymentId {
            paymentIds.append(paymentResultId)
        } else if let businessResult = model.businessResult {
            if let receiptLists = businessResult.getReceiptIdList() {
                paymentIds = receiptLists
            } else if let receiptId = businessResult.getReceiptId() {
                paymentIds.append(receiptId)
            }
        }

        let campaignId: String? = model.amountHelper?.campaign?.id?.stringValue

        model.shouldSearchPointsAndDiscounts = false
        let platform = MLBusinessAppDataService().getAppIdentifier().rawValue
        model.mercadoPagoServices
        model.mercadoPagoServices.getPointsAndDiscounts(url: PXServicesURLConfigs.MP_API_BASE_URL, uri: PXServicesURLConfigs.MP_POINTS_URI, paymentIds: paymentIds, campaignId: campaignId, platform: platform, callback: { [weak self] (pointsAndBenef) in
                guard let strongSelf = self else { return }
                strongSelf.model.pointsAndDiscounts = pointsAndBenef
                strongSelf.executeNextStep()
            }, failure: { [weak self] () in
                print("Fallo el endpoint de puntos y beneficios")
                guard let strongSelf = self else { return }
                strongSelf.executeNextStep()
        })
    }

    func getInstructions() {
        guard let paymentResult = model.paymentResult else {
            fatalError("Get Instructions - Payment Result does no exist")
        }

        guard let paymentId = paymentResult.paymentId else {
            fatalError("Get Instructions - Payment Id does no exist")
        }

        guard let paymentTypeId = paymentResult.paymentData?.getPaymentMethod()?.paymentTypeId else {
            fatalError("Get Instructions - Payment Method Type Id does no exist")
        }

        model.mercadoPagoServices.getInstructions(paymentId: Int64(paymentId)!, paymentTypeId: paymentTypeId, callback: { [weak self] (instructions) in
            self?.model.instructionsInfo = instructions
            self?.executeNextStep()

            }, failure: {[weak self] (error) in

                let mpError = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.GET_INSTRUCTIONS.rawValue)
                self?.showError(error: mpError)

        })
    }
}
