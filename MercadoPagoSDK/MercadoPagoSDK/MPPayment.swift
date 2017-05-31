//
//  MPPayment.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 26/4/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

open class MPPayment: NSObject {
    
    open var email : String!
    open var preferenceId : String!
    open var publicKey : String!
    open var paymentMethodId : String!
    open var installments : Int = 0
    open var issuerId : String?
    open var tokenId : String?
    open var binaryMode = false

    init(email : String, preferenceId : String, publicKey : String, paymentMethodId : String, installments : Int = 0, issuerId : String = "", tokenId : String = "") {
        self.preferenceId = preferenceId
        self.publicKey = publicKey
        self.paymentMethodId = paymentMethodId
        self.installments = installments
        self.issuerId = issuerId
        self.tokenId = tokenId
        self.email = email
    }
    
    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }
    
    open func toJSON() -> [String:Any] {
        var obj:[String:Any] = [
            "public_key": self.publicKey,
            "payment_method_id": self.paymentMethodId,
            "pref_id" : self.preferenceId,
            ]
        
        if self.tokenId != nil && self.tokenId?.characters.count > 0 {
            obj["token"] = self.tokenId!
        }
        
        obj["binary_mode"] = self.binaryMode
        
        obj["installments"] = self.installments
        
        if self.issuerId != nil && self.issuerId?.characters.count > 0 {
            obj["issuer_id"] = self.issuerId
        }
        
        let payer = Payer(email : self.email)
        obj["payer"] = payer.toJSON()
        
        return obj
    }
}

open class CustomerPayment: MPPayment {
    
    open var customerId : String!
    
    init(email: String, preferenceId: String, publicKey: String, paymentMethodId: String, installments : Int = 0, issuerId : String = "", tokenId : String = "", customerId : String){
        super.init(email: email, preferenceId: preferenceId, publicKey: publicKey, paymentMethodId: paymentMethodId, installments: installments, tokenId : tokenId)
        self.customerId = customerId
    }
    
    open override func toJSON() -> [String:Any] {
        var customerPaymentObj : [String:Any] = super.toJSON()
        // Override payer object
        let payer = Payer(_id: customerId, email: self.email)
        customerPaymentObj["payer"] = payer.toJSON()
        return customerPaymentObj
    }

}

open class BlacklabelPayment: MPPayment {
    
    open override func toJSON() -> [String:Any] {
        var blacklabelPaymentObj : [String:Any] = super.toJSON()
        // Override payer object with groupsPayer (which includes AT in its body)
        let payer = GroupsPayer(email: self.email)
        blacklabelPaymentObj["payer"] = payer.toJSON()
        return blacklabelPaymentObj
    }
}


open class MPPaymentFactory {
    
    open class func createMPPayment(email: String, preferenceId: String, publicKey: String, paymentMethodId: String, installments : Int = 0, issuerId : String = "", tokenId : String = "", customerId : String? = nil, isBlacklabelPayment : Bool) -> MPPayment {
        
        if !String.isNullOrEmpty(customerId) {
            return CustomerPayment(email: email, preferenceId: preferenceId, publicKey: publicKey, paymentMethodId: paymentMethodId, installments: installments, issuerId : issuerId, tokenId : tokenId, customerId: customerId!)
        } else if (isBlacklabelPayment) {
            return BlacklabelPayment(email: email, preferenceId: preferenceId, publicKey: publicKey, paymentMethodId: paymentMethodId, installments: installments, issuerId : issuerId, tokenId : tokenId)
        }
        
        return MPPayment(email: email, preferenceId: preferenceId, publicKey: publicKey, paymentMethodId: paymentMethodId, installments: installments, issuerId : issuerId, tokenId : tokenId)
        
    }

}
