//
//  HookStoreTest.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 11/29/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import XCTest

class PXHookDataTest : BaseTest {

    func test_addData() {
        PXCheckoutStore.sharedInstance.addData(forKey: "key", value: "value")
        let value = PXCheckoutStore.sharedInstance.getData(forKey: "key")
        XCTAssertEqual("value", value as! String)
    }

    func test_removeData() {
        PXCheckoutStore.sharedInstance.addData(forKey: "key", value: "value")
        var value = PXCheckoutStore.sharedInstance.getData(forKey: "key")
        XCTAssertEqual("value", value as! String)

        PXCheckoutStore.sharedInstance.remove(key: "key")
        value = PXCheckoutStore.sharedInstance.getData(forKey: "key")
        XCTAssertNil(value)
    }

    override func tearDown() {
         super.tearDown()
        PXCheckoutStore.sharedInstance.removeAll()
    }

}
