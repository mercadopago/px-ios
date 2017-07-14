//
//  TrackerTest.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 6/9/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class DummyContext: MPXTracker {
    static var mpxPublicKey = "DPKey"
    static var mpxCheckoutVersion = "DVersion"
    static var mpxPlatform = "DPlatform"
    static var mpxSiteId = "DSite"
    static var mpxPlatformType = "DPlatformType"
    static var testScreenId = "Screen Id"
    static var testScreenName = "Screen Name"
    static var testAction = "Action"
    static var testCategory = "Category"
    static var testLabel = "Label"
    static var testValue = "Value"
}

class TrackerTest: XCTestCase {
    func testEventJSON() {
        let jsonEvent = DummyContext.generateJSONEvent(screenId: DummyContext.testScreenId, screenName: DummyContext.testScreenName, action: DummyContext.testAction, category: DummyContext.testCategory, label: DummyContext.testLabel, value:DummyContext.testValue)
        let testEventJSON = eventJSONToTest()
        let event = (jsonEvent["events"] as! [[String:Any]])[0]
        let eventTester = (testEventJSON["events"] as! [[String:Any]])[0]
        XCTAssertEqual(JSONHandler.jsonCoding(jsonEvent["application"] as! [String : Any]), JSONHandler.jsonCoding(testEventJSON["application"] as! [String : Any]))
        XCTAssertEqual(event["type"] as! String, eventTester["type"] as! String)
        XCTAssertEqual(event["screen_id"] as! String, eventTester["screen_id"] as! String)
        XCTAssertEqual(event["screen_name"] as! String, eventTester["screen_name"] as! String)
        XCTAssertEqual(event["action"] as! String, eventTester["action"] as! String)
        XCTAssertEqual(event["category"] as! String, eventTester["category"] as! String)
        XCTAssertEqual(event["label"] as! String, eventTester["label"] as! String)
        XCTAssertEqual(event["value"] as! String, eventTester["value"] as! String)
    }
    func testScreenJSON() {
        let jsonScreen = DummyContext.generateJSONScreen(screenId: DummyContext.testScreenId, screenName: DummyContext.testScreenName, metadata: [:])
        let testScreenJSON = screenJSONToTest()
        let event = (jsonScreen["events"] as! [[String:Any]])[0]
        let eventTester = (testScreenJSON["events"] as! [[String:Any]])[0]
        XCTAssertEqual(JSONHandler.jsonCoding(jsonScreen["application"] as! [String : Any]), JSONHandler.jsonCoding(testScreenJSON["application"] as! [String : Any]))
        XCTAssertEqual(event["type"] as! String, eventTester["type"] as! String)
        XCTAssertEqual(event["screen_id"] as! String, eventTester["screen_id"] as! String)
        XCTAssertEqual(event["screen_name"] as! String, eventTester["screen_name"] as! String)
     //   XCTAssertTrue(event["additional_info"] as! [String:Any] == eventTester["additional_info"] as! [String:Any])

    }
    func screenJSONToTest() -> [String:Any] {
        let obj: [String:Any] = [
            "application": applicationJSON(),
            "events": [screenValuesJSON()]]
        return obj
    }
    func eventJSONToTest() -> [String:Any] {
        let obj: [String:Any] = [
            "application": applicationJSON(),
            "events": [eventValuesJSON()]
        ]
        return obj
    }
    func applicationJSON() -> [String:Any] {
        let obj: [String:Any] = [
            "public_key": MercadoPagoContext.sharedInstance.publicKey(),
            "checkout_version": MercadoPagoContext.sharedInstance.sdkVersion(),
            "platform": "Native"
        ]
        return obj
    }
    func eventValuesJSON() -> [String:Any] {
        let obj: [String:Any] = [
            "type": "action",
            "screen_id": DummyContext.testScreenId,
            "screen_name": DummyContext.testScreenName,
            "action": DummyContext.testAction,
            "category": DummyContext.testCategory,
            "label": DummyContext.testLabel,
            "value": DummyContext.testValue
        ]
        return obj
    }
    func screenValuesJSON() -> [String:Any] {
        let obj: [String:Any] = [
            "type": "screenview",
            "screen_id": DummyContext.testScreenId,
            "screen_name": DummyContext.testScreenName,
            "additional_info": [:]
        ]
        return obj
    }
}
