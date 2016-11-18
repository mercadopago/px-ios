//
//  CustomerPaymentMethod.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 4/8/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class CustomerPaymentMethod: NSObject, CardInformation {
  
    
    var _id : String!
    var _description : String!
    var type : String!
    var value : String!
    
    var securityCode : SecurityCode = SecurityCode()
    
    open class func fromJSON(_ json : NSDictionary) -> CustomerPaymentMethod {
        let customerPaymentMethod = CustomerPaymentMethod()
        
        if json["id"] != nil && !(json["id"]! is NSNull) {
            customerPaymentMethod._id = json["id"] as! String
        }

        if json["description"] != nil && !(json["description"]! is NSNull) {
            customerPaymentMethod._description = json["description"] as! String
        }
        
        if json["type"] != nil && !(json["type"]! is NSNull) {
            customerPaymentMethod.type = json["type"] as! String
        }
        
        if json["value"] != nil && !(json["value"]! is NSNull) {
            customerPaymentMethod.value = json["value"] as! String
        }
        
        return customerPaymentMethod
    }
    
    
    public func getIssuer() -> Issuer? {
        return nil
    }

    
    open func toJSON() -> [String:Any] {
        let obj:[String:Any] = [
            "_id": self._id,
            "_description": self._description == nil ? "" : self._description!,
            "type" : self.type,
            "value": self.value
        ]
        
        return obj
    }
    
    
    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func isSecurityCodeRequired() -> Bool {
        return true;
    }
    
    open func getCardId() -> String {
        return self.value
    }
    
    open func getCardSecurityCode() -> SecurityCode {
        return self.securityCode
    }
    
    open func getCardDescription() -> String {
        return self._description
    }
    
    open func getPaymentMethod() -> PaymentMethod {
        let pm = PaymentMethod()
        pm._id = self._id
        return pm
    }
    
    open func getPaymentMethodId() -> String {
        return self._id
    }
    
    open func getCardBin() -> String? {
        return "XXXX"
    }
    
    open func getCardLastForDigits() -> String? {
        return "XXXX"
    }
    
    open func setupPaymentMethodSettings(_ settings : [Setting]) {
        self.securityCode = settings[0].securityCode
    }
    
}
