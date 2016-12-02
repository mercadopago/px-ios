//
//  CheckoutPreferenceTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 21/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class CheckoutPreferenceTest: XCTestCase {
    
    var preference : CheckoutPreference?
    
    override func setUp() {
        super.setUp()
        self.preference = MockBuilder.buildCheckoutPreference()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFromJSON() {
        
        let obj:[String:AnyObject] = [
            "id": "id" as AnyObject,
        ]
        
        let preferenceResult = CheckoutPreference.fromJSON(NSDictionary(dictionary: obj))
        XCTAssertEqual(preferenceResult._id, "id")
    }
    
    func testToJSON() {
       
    }
    
    func testGetAmount() {
        preference?.items?.removeAll()
        XCTAssertEqual(preference?.getAmount(), 0)
        
        let item1 = Item(_id: "id1", title : "item 1 title", quantity: 1, unitPrice: 10)
        let item2 = Item(_id: "id2", title : "item 2 title", quantity: 3, unitPrice: 5)
        let item3 = Item(_id: "id3", title : "item 3 title", quantity: 2, unitPrice: 2)
        self.preference!.items = [item1, item2, item3]
        
        XCTAssertEqual(preference?.getAmount(), 29)
        preference?.items?.remove(at: 1)
        XCTAssertEqual(preference?.getAmount(), 14)
        
    }
    
    func testExcludedPaymentTypes() {
       // XCTAssertEqual(MockBuilder.getMockPaymentTypeIds(), preference?.getExcludedPaymentTypes())
        
//        preference!.paymentMethods?.excludedPaymentTypes?.removeAll()
//        XCTAssertNil(preference!.getExcludedPaymentTypes())
//        
    }
    
    func testExcludedPaymentMethods() {
        
        
    }
    
    
}
