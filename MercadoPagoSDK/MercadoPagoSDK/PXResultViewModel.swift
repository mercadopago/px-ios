//
//  PXResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 20/10/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoPXTracking

public class PXResultViewModel: PXResultViewModelInterface {

    var screenName: String { return TrackingUtil.SCREEN_NAME_PAYMENT_RESULT }
    var screenId: String { return TrackingUtil.SCREEN_ID_PAYMENT_RESULT }

    func trackInfo() {
        var metadata = [TrackingUtil.METADATA_PAYMENT_IS_EXPRESS: TrackingUtil.IS_EXPRESS_DEFAULT_VALUE,
                        TrackingUtil.METADATA_PAYMENT_STATUS: self.getPaymentStatus(),
                        TrackingUtil.METADATA_PAYMENT_STATUS_DETAIL: self.getPaymentStatusDetail(),
                        TrackingUtil.METADATA_PAYMENT_ID: self.getPaymentId() ?? ""]
        if let pm = self.getPaymentData().getPaymentMethod() {
            metadata[TrackingUtil.METADATA_PAYMENT_METHOD_ID] = pm.paymentMethodId
        }
        if let issuer = self.getPaymentData().getIssuer() {
            metadata[TrackingUtil.METADATA_ISSUER_ID] = issuer.issuerId
        }

        let finalId = "\(screenId)/\(self.getPaymentStatus())"

        var name = screenName
        if self.isCallForAuth() {
            name = TrackingUtil.SCREEN_NAME_PAYMENT_RESULT_CALL_FOR_AUTH
        }

        MPXTracker.sharedInstance.trackScreen(screenId: finalId, screenName: name, properties: metadata)
    }

    func getPaymentData() -> PaymentData {
        return self.paymentResult.paymentData!
    }

    func setCallback(callback: @escaping ((PaymentResult.CongratsState) -> Void)) {
        self.callback = callback
    }

    func getPaymentStatus() -> String {
        return self.paymentResult.status
    }

    func getPaymentStatusDetail() -> String {
        return self.paymentResult.statusDetail
    }

    func getPaymentId() -> String? {
        return self.paymentResult.paymentId
    }
    func isCallForAuth() -> Bool {
        return self.paymentResult.isCallForAuth()
    }

    open var paymentResult: PaymentResult
    open var instructionsInfo: InstructionsInfo?
    open var preference: PaymentResultScreenPreference
    var callback: ((PaymentResult.CongratsState) -> Void)!
    let amount: Double

    let warningStatusDetails = [RejectedStatusDetail.INVALID_ESC, RejectedStatusDetail.CALL_FOR_AUTH, RejectedStatusDetail.BAD_FILLED_CARD_NUMBER, RejectedStatusDetail.CARD_DISABLE, RejectedStatusDetail.INSUFFICIENT_AMOUNT, RejectedStatusDetail.BAD_FILLED_DATE, RejectedStatusDetail.BAD_FILLED_SECURITY_CODE, RejectedStatusDetail.BAD_FILLED_OTHER]

    init(paymentResult: PaymentResult, amount: Double, instructionsInfo: InstructionsInfo? = nil, paymentResultScreenPreference: PaymentResultScreenPreference = PaymentResultScreenPreference()) {
        self.paymentResult = paymentResult
        self.instructionsInfo = instructionsInfo
        self.preference =  paymentResultScreenPreference
        self.amount = amount
    }

    func primaryResultColor() -> UIColor {
        if isAccepted() {
            return ThemeManager.shared.successColor()
        }
        if isError() {
            return ThemeManager.shared.rejectedColor()
        }
        if isWarning() {
            return ThemeManager.shared.warningColor()
        }
        return .pxWhite
    }

    func isAccepted() -> Bool {
        if self.paymentResult.isApproved() || self.paymentResult.isInProcess() || self.paymentResult.isPending() {
            return true
        } else {
            return false
        }
    }

    func isWarning() -> Bool {
        if !self.paymentResult.isRejected() {
            return false
        }
        if warningStatusDetails.contains(self.paymentResult.statusDetail) {
            return true
        }

        return false
    }

    func isError() -> Bool {
        if !self.paymentResult.isRejected() {
            return false
        }
        return !isWarning()
    }
}
