//
//  ItemTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class ItemTest: BaseTest {

    func testInit() {
        let item = Item(itemId: "id", title: "title", quantity: 3, unitPrice: 500)
        XCTAssertEqual(item.itemId, "id")
        XCTAssertEqual(item.title, "title")
        XCTAssertEqual(item.quantity, 3)
        XCTAssertEqual(item.unitPrice, 500)
    }
}
