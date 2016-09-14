//
//  MercadoPagoContextTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 21/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class MercadoPagoContextTest: BaseTest {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        MercadoPagoContext.setCustomerURI("")
        MercadoPagoContext.setMerchantAccessToken("")
        MercadoPagoContext.setPrivateKey("")
    }
    
    func testKeyType() {
        
        XCTAssertTrue(MercadoPagoContext.privateKey().isEmpty)
        MercadoPagoContext.setPublicKey("public")
        XCTAssertEqual(MercadoPagoContext.keyType(),MercadoPagoContext.PUBLIC_KEY)
        
        MercadoPagoContext.setPrivateKey("private")
        XCTAssertEqual(MercadoPagoContext.keyType(),MercadoPagoContext.PRIVATE_KEY)
        
        MercadoPagoContext.setPublicKey("public 2")
        XCTAssertEqual(MercadoPagoContext.keyType(),MercadoPagoContext.PRIVATE_KEY)
    }

    func testCustomerURI(){
        MercadoPagoContext.setCustomerURI("customerUri")
        XCTAssertEqual(MercadoPagoContext.customerURI(), "customerUri")
    }

    func testMercchantAccessToken(){
        MercadoPagoContext.setMerchantAccessToken("merchantAccessToken")
        XCTAssertEqual(MercadoPagoContext.merchantAccessToken(), "merchantAccessToken")
    }

    func testCustomerUri(){
        MercadoPagoContext.setPreferenceURI("preferenceUri")
        XCTAssertEqual(MercadoPagoContext.preferenceURI(), "preferenceUri")
    }

    func testKeyValue(){
        MercadoPagoContext.setPublicKey("public_key")
        MercadoPagoContext.setPrivateKey("private_key")

        XCTAssertEqual(MercadoPagoContext.keyValue(true), "public_key")
        
       // XCTAssertEqual(MercadoPagoContext.keyValue(), "private_key")
        
        MercadoPagoContext.setPrivateKey("")
        
        XCTAssertEqual(MercadoPagoContext.keyValue(), "public_key")
    }
}
