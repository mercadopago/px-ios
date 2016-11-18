//
//  CardInformation.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 12/8/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objc
public protocol CardInformation : CardInformationForm {
    
    func isSecurityCodeRequired() -> Bool
    
    func getCardId() -> String
    
    func getCardSecurityCode() -> SecurityCode
    
    func getCardDescription() -> String
    
    func setupPaymentMethodSettings(_ settings : [Setting])
    
    func getPaymentMethod() -> PaymentMethod
    
    func getPaymentMethodId() -> String
    
    func getIssuer() -> Issuer?
}
@objc
public protocol CardInformationForm : NSObjectProtocol {
    
    
    func getCardBin() -> String?
    
    func getCardLastForDigits() -> String?
}
