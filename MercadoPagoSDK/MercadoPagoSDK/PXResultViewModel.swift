//
//  PXResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 20/10/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

public class PXResultViewModel: NSObject {

    open var paymentResult: PaymentResult
    open var instructionsInfo: InstructionsInfo?
    open var preference: PaymentResultScreenPreference
    var callback: ((PaymentResult.CongratsState) -> Void)!
    let  amount: Double

    let warningStatusDetails = [RejectedStatusDetail.INVALID_ESC, RejectedStatusDetail.CALL_FOR_AUTH, RejectedStatusDetail.BAD_FILLED_CARD_NUMBER, RejectedStatusDetail.CARD_DISABLE, RejectedStatusDetail.INSUFFICIENT_AMOUNT, RejectedStatusDetail.BAD_FILLED_DATE, RejectedStatusDetail.BAD_FILLED_SECURITY_CODE, RejectedStatusDetail.BAD_FILLED_OTHER]

    init(paymentResult: PaymentResult, amount: Double, instructionsInfo: InstructionsInfo? = nil, paymentResultScreenPreference: PaymentResultScreenPreference = PaymentResultScreenPreference()) {
        self.paymentResult = paymentResult
        self.instructionsInfo = instructionsInfo
        self.preference =  paymentResultScreenPreference
        self.amount = amount
    }

    func primaryResultColor() -> UIColor {
        if isAccepted() {
            return .pxGreenMp
        }
        if isError() {
            return .pxRedMp
        }
        if isWarning() {
            return .pxOrangeMp
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
