//
//  MPPayment.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 26/4/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class MPPayment: NSObject {
    
    public var email : String!
    public var preferenceId : String!
    public var publicKey : String!
    public var paymentMethodId : String!
    public var installments : Int = 0
    public var issuerId : String?
    public var tokenId : String?
    

    init(email : String, preferenceId : String, publicKey : String, paymentMethodId : String, installments : Int = 0, issuerId : String = "", tokenId : String = "") {
        self.email = email
        self.preferenceId = preferenceId
        self.publicKey = publicKey
        self.paymentMethodId = paymentMethodId
        self.installments = installments
        self.issuerId = issuerId
        self.tokenId = tokenId
    }
    
    public func toJSONString() -> String {
        var obj:[String:AnyObject] = [
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
        
        return JSON(obj).toString()
    }
    
}
