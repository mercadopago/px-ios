//
//  SavedCard.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

public class SavedCardToken : CardToken {
    
    public var cardId : String?
    public var securityCodeRequired : Bool = true
    
    public init(cardId : String, securityCode : String) {
        super.init()
        self.cardId = cardId
        self.securityCode = securityCode
    }
    
    public init(card : CardInformation, securityCode : String?, securityCodeRequired: Bool) {
        super.init()
        self.cardId = card.getCardId()
        self.securityCode = securityCode
        self.securityCodeRequired = securityCodeRequired
    }
    
    public override func validate() -> Bool {
        return self.validateCardId() && (!securityCodeRequired || self.validateSecurityCodeNumbers())
    }
    
    public func validateCardId() -> Bool {
        return !String.isNullOrEmpty(cardId) && String.isDigitsOnly(cardId!)
    }
    
    public func validateSecurityCodeNumbers() -> Bool {
        let isEmptySecurityCode : Bool = String.isNullOrEmpty(self.securityCode)
        return !isEmptySecurityCode && self.securityCode!.characters.count >= 3 && self.securityCode!.characters.count <= 4
    }
    
    public override func isCustomerPaymentMethod() -> Bool {
        return true
    }
    
    public override func toJSONString() -> String {
        let obj:[String:AnyObject] = [
            "card_id": String.isNullOrEmpty(self.cardId) ? JSON.null : self.cardId!,
            "security_code" : String.isNullOrEmpty(self.securityCode) ? JSON.null : self.securityCode!,
            "device" : self.device == nil ? JSON.null : self.device!.toJSONString()
        ]
        return JSON(obj).toString()
    }
}