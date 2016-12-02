//
//  CardTokenTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class CardTokenTest: BaseTest {

    
    func testInit(){
        let cardToken = CardToken(cardNumber: "cardNumber", expirationMonth: 1, expirationYear: 20, securityCode: "123", cardholderName: "cardholderName", docType: "docType", docNumber: "docNumber")
        
        
        XCTAssertEqual(cardToken.cardNumber, "cardNumber")
        XCTAssertEqual(cardToken.expirationMonth, 1)
        XCTAssertEqual(cardToken.expirationYear, 2020)
        XCTAssertEqual(cardToken.securityCode, "123")
        XCTAssertNotNil(cardToken.cardholder)
        XCTAssertEqual(cardToken.cardholder?.name, "cardholderName")
        
        XCTAssertEqual(cardToken.cardholder?.name, "cardholderName")
        XCTAssertNotNil(cardToken.cardholder?.identification)
        
        XCTAssertEqual(cardToken.cardholder?.identification?.number, "docNumber")
        XCTAssertEqual(cardToken.cardholder?.identification?.type, "docType")
    }
    
}
