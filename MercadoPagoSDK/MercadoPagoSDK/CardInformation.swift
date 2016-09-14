//
//  CardInformation.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 12/8/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objc
public protocol CardInformation : NSObjectProtocol {
    
    func isSecurityCodeRequired() -> Bool
    
    func getCardId() -> String
    
    func getCardSecurityCode() -> SecurityCode
    
    func getCardDescription() -> String
    
    func getPaymentMethod() -> PaymentMethod
    
    func getPaymentMethodId() -> String
    
    func getCardBin() -> String?
    
    func getCardLastForDigits() -> String?
    
    func setupPaymentMethodSettings(settings : [Setting])
}
