//
//  ItemTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class ItemTest: BaseTest {
    
    func testInit(){
        let item = Item(_id: "id", title: "title", quantity: 3, unitPrice: 500)
        XCTAssertEqual(item._id, "id")
        XCTAssertEqual(item.title, "title")
        XCTAssertEqual(item.quantity, 3)
        XCTAssertEqual(item.unitPrice, 500)
    }
    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("Item")!
        let itemFromJSON = Item.fromJSON(json)
        XCTAssertEqual(itemFromJSON, itemFromJSON)
    }
    
}
