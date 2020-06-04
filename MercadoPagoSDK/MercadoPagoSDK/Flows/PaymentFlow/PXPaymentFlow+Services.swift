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
        guard model.amountHelper?.getPaymentData() != nil, model.checkoutPreference != nil else {
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
        headers[MercadoPagoService.HeaderField.security.rawValue] = PXCheckoutStore.sharedInstance.getSecurityType()

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
        var paymentMethodsIds = [String]()
        if let split = splitAccountMoney, let paymentMethod = split.paymentMethod?.id {
            paymentMethodsIds.append(paymentMethod)
        }
        if let paymentResult = model.paymentResult {
            if let paymentId = paymentResult.paymentId {
                paymentIds.append(paymentId)
            }
            if let paymentMethodId = paymentResult.paymentData?.paymentMethod?.id {
                paymentMethodsIds.append(paymentMethodId)
            }
        } else if let businessResult = model.businessResult {
            if let receiptLists = businessResult.getReceiptIdList() {
                paymentIds = receiptLists
            } else if let receiptId = businessResult.getReceiptId() {
                paymentIds.append(receiptId)
            }
            if let paymentMethodId = businessResult.getPaymentMethodId() {
                paymentMethodsIds.append(paymentMethodId)
            }
        }

        let campaignId: String? = model.amountHelper?.campaign?.id?.stringValue

        // ifpe is always false until KyC callback can return to one tap
        let ifpe = false

        model.shouldSearchPointsAndDiscounts = false
        let platform = MLBusinessAppDataService().getAppIdentifier().rawValue
        model.mercadoPagoServices.getPointsAndDiscounts(url: PXServicesURLConfigs.MP_API_BASE_URL, uri: PXServicesURLConfigs.MP_POINTS_URI, paymentIds: paymentIds, paymentMethodsIds: paymentMethodsIds, campaignId: campaignId, platform: platform, ifpe: ifpe, callback: { [weak self] (pointsAndBenef) in
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
