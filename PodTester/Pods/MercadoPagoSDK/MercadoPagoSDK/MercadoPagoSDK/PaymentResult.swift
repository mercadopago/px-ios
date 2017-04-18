//
//  PaymentResult.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 2/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PaymentResult: NSObject {
    open var paymentData: PaymentData?
    open var status: String
    open var statusDetail: String
    open var payerEmail: String?
    open var _id: String?
    open var statementDescription: String?
    
    public init (payment: Payment, paymentData: PaymentData){
        self.status = payment.status
        self.statusDetail = payment.statusDetail
        self.paymentData = paymentData
        self._id = payment._id
        self.payerEmail = payment.payer.email
        self.statementDescription = payment.statementDescriptor
    }
    
    public init (status: String, statusDetail: String, paymentData: PaymentData, payerEmail:String?, id: String?, statementDescription: String?) {
        self.status = status
        self.statusDetail = statusDetail
        self.paymentData = paymentData
        self.payerEmail = payerEmail
        self._id = id
        self.statementDescription = statementDescription
    }
}
