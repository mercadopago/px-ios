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
        PXHookStore.sharedInstance.addData(forKey: "key", value: "value")
        let value = PXHookStore.sharedInstance.getData(forKey: "key")
        XCTAssertEqual("value", value as! String)
    }

    func test_removeData() {
        PXHookStore.sharedInstance.addData(forKey: "key", value: "value")
        var value = PXHookStore.sharedInstance.getData(forKey: "key")
        XCTAssertEqual("value", value as! String)

        PXHookStore.sharedInstance.remove(key: "key")
        value = PXHookStore.sharedInstance.getData(forKey: "key")
        XCTAssertNil(value)
    }

    override func tearDown() {
         super.tearDown()
        PXHookStore.sharedInstance.removeAll()
    }

}
