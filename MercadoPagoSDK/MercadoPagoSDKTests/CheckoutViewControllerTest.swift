//
//  CheckoutViewControllerTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 22/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class CheckoutViewControllerTest: BaseTest {
    
    var checkoutViewController : MockCheckoutViewController?
    var preference : CheckoutPreference?
    var selectedPaymentMethod : PaymentMethod?
    var selectedPayerCost : PayerCost?
    var selectedIssuer : Issuer?
    var createdToken : Token?
    
    override func setUp() {
        
    }
}

