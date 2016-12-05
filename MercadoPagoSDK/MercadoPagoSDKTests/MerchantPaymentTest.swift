//
//  MerchantPaymentTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class MerchantPaymentTest: BaseTest {
    
    let items = [MockBuilder.buildItem("id1", quantity: 1, unitPrice: 2), MockBuilder.buildItem("id2", quantity: 3, unitPrice: 5)]
    let amexPaymentMethod = MockBuilder.buildPaymentMethod("amex")
    
    func testInit(){
        let merchantPayment = MerchantPayment(items: self.items, installments: 12, cardIssuer: nil, tokenId: "tokenId", paymentMethod: amexPaymentMethod, campaignId: 0)
        
        XCTAssertEqual(merchantPayment.items!, items)
        XCTAssertEqual(merchantPayment.installments, 12)
        XCTAssertNil(merchantPayment.issuer)
        XCTAssertEqual(merchantPayment.cardTokenId, "tokenId")
        XCTAssertEqual(merchantPayment.paymentMethod, amexPaymentMethod)
        XCTAssertEqual(merchantPayment.campaignId, 0)
        
    }
    
}
