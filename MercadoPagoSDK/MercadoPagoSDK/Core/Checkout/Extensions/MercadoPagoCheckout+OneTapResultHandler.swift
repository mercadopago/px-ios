//
//  MercadoPagoCheckout+OneTapResultHandler.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 03/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension MercadoPagoCheckout: PXOneTapResultHandlerProtocol {
    func finishOneTap(paymentData: PXPaymentData, splitAccountMoney: PXPaymentData?, pointsAndDiscounts: PXPointsAndDiscounts?) {
        self.viewModel.updateCheckoutModel(paymentData: paymentData)
        self.viewModel.splitAccountMoney = splitAccountMoney
        self.viewModel.pointsAndDiscounts = pointsAndDiscounts
        self.executeNextStep()
    }

    func cancelOneTap() {
        self.viewModel.prepareForNewSelection()
        self.executeNextStep()
    }

    func cancelOneTapForNewPaymentMethodSelection() {
        self.viewModel.checkoutPreference.setCardId(cardId: "cards")
        self.viewModel.prepareForNewSelection()
        self.executeNextStep()
    }

    func exitCheckout() {
        self.finish()
    }

    func finishOneTap(paymentResult: PaymentResult, instructionsInfo: PXInstructions?, pointsAndDiscounts: PXPointsAndDiscounts?) {
        self.setPaymentResult(paymentResult: paymentResult)
        self.viewModel.instructionsInfo = instructionsInfo
        self.viewModel.pointsAndDiscounts = pointsAndDiscounts
        self.executeNextStep()
    }

    func finishOneTap(businessResult: PXBusinessResult, paymentData: PXPaymentData, splitAccountMoney: PXPaymentData?, pointsAndDiscounts: PXPointsAndDiscounts?) {
        self.viewModel.businessResult = businessResult
        self.viewModel.paymentData = paymentData
        self.viewModel.splitAccountMoney = splitAccountMoney
        self.viewModel.pointsAndDiscounts = pointsAndDiscounts
        self.executeNextStep()
    }
}
