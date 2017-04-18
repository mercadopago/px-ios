//
//  CallbackCancelDelegate.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 10/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class CallbackCancelTableViewCell : UITableViewCell {

    var callbackCancel : ((Void) -> Void)?
    var defaultCallback : ((Void) -> Void)?
    var callbackStatus: ((_ payment : Payment, _ status : MPStepBuilder.CongratsState) -> Void)?
    var payment: Payment?
    var status: MPStepBuilder.CongratsState?
    
    func getCallbackStatus() -> ((_ payment : Payment, _ status : MPStepBuilder.CongratsState) -> Void){
        return callbackStatus!
    }
    func setCallbackStatus(callback: @escaping (_ payment : Payment, _ status : MPStepBuilder.CongratsState) -> Void, payment: Payment,status: MPStepBuilder.CongratsState){
        callbackStatus = callback
        self.payment = payment
        self.status = status
    }
    
    func invokeCallbackCancel() {
        self.callbackCancel!()
    }

    func invokeDefaultCallback(){
        if self.defaultCallback != nil {
            self.defaultCallback!()
        }
    }
    func invokeCallback(){
        if let callbackStatus = self.callbackStatus , let payment = payment , let status = status  {
            callbackStatus(payment, status)
        }
    }


    
}
