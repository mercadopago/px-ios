//
//  SettingTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class SettingTest: BaseTest {
    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("Setting")!
        let settingCodeFromJSON = Setting.fromJSON(json)
        XCTAssertEqual(settingCodeFromJSON, settingCodeFromJSON)
    }
    
}
