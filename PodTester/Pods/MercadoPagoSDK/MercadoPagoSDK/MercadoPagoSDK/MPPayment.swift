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
    

    init(email : String, preferenceId : String, publicKey : String, paymentMethodId : String, installments : Int = 0, issuerId : String = "", tokenId : String = "") {
        self.email = email
        self.preferenceId = preferenceId
        self.publicKey = publicKey
        self.paymentMethodId = paymentMethodId
        self.installments = installments
        self.issuerId = issuerId
        self.tokenId = tokenId
    }
    
    open func toJSONString() -> String {
        var obj:[String:Any] = [
            "public_key": self.publicKey,
            "email": self.email,
            "payment_method_id": self.paymentMethodId,
            "pref_id" : self.preferenceId,
        ]
        
        if self.tokenId != nil && self.tokenId?.characters.count > 0 {
                obj["token"] = self.tokenId!
        }
        
        obj["installments"] = self.installments
        
        if self.issuerId != nil && self.issuerId?.characters.count > 0 {
            obj["issuer_id"] = self.issuerId
        }
        
        return JSONHandler.jsonCoding(obj)
    }
    
}
