//
//  CallbackCancelDelegate.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 10/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers
open class CallbackCancelTableViewCell: UITableViewCell {

    var callbackCancel: (() -> Void)?
    var defaultCallback: (() -> Void)?
    var callbackStatusTracking: ((_ paymentResult: PaymentResult, _ status: PaymentResult.CongratsState) -> Void)?
    var callbackStatus: ((_ status: PaymentResult.CongratsState) -> Void)?
    var paymentResult: PaymentResult?
    var status: PaymentResult.CongratsState?

    func getCallbackStatus() -> (( _ status: PaymentResult.CongratsState) -> Void) {
        return callbackStatus!
    }
    func setCallbackStatus(callback: @escaping ( _ status: PaymentResult.CongratsState) -> Void, status: PaymentResult.CongratsState) {
        callbackStatus = callback
        self.status = status
    }

    func setCallbackStatusTracking(callback: @escaping (_ paymentResult: PaymentResult, _ status: PaymentResult.CongratsState) -> Void, paymentResult: PaymentResult, status: PaymentResult.CongratsState) {
        callbackStatusTracking = callback
        self.paymentResult = paymentResult
        self.status = status
    }

    func invokeCallbackCancel() {
        self.callbackCancel!()
    }

    func invokeDefaultCallback() {
        if self.defaultCallback != nil {
            self.defaultCallback!()
        }
    }
    func invokeCallback() {
        if let paymentResult = paymentResult, let callbackStatusTracking = self.callbackStatusTracking, let status = status {
            callbackStatusTracking(paymentResult, status)
        } else if let callbackStatus = self.callbackStatus, let status = status {
            callbackStatus(status)
        }
    }

}
