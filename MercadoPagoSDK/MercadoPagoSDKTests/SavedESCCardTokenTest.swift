//
//  SavedESCCardTokenTest.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 7/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class SavedESCCardTokenTest: BaseTest {

    func testInit() {
        let savedESCCardToken = SavedESCCardToken(cardId: "cardId", securityCode: "123", requireESC: false)
        XCTAssertEqual(savedESCCardToken.cardId, "cardId")
        XCTAssertEqual(savedESCCardToken.securityCode!, "123")
        XCTAssertFalse(savedESCCardToken.requireESC)
    }

    func testInitWithCard() {
        let savedESCCardToken = SavedESCCardToken(cardId: "cardId", esc: "esc", requireESC: false)
        XCTAssertEqual(savedESCCardToken.cardId, "cardId")
        XCTAssertEqual(savedESCCardToken.esc, "esc")
        XCTAssertFalse(savedESCCardToken.requireESC)
        XCTAssertEqual(savedESCCardToken.securityCode!, "")
        //XCTAssertEqual(savedESCCardToken.device!.fingerprint!.devicesID(), Device().fingerprint!.devicesID())
    }

    func testJSON() {
        let savedESCCardToken = SavedESCCardToken(cardId: "cardId", esc: "esc", requireESC: false)
        let json = savedESCCardToken.toJSON()
        XCTAssertEqual(json["card_id"] as! String, "cardId")
        XCTAssertEqual(json["security_code"] as! String, "")
        XCTAssertEqual(json["require_esc"] as! Bool, false)
        XCTAssertEqual(json["esc"] as! String, "esc")
       // XCTAssertEqual(json["device"] as!  [String: Any], savedESCCardToken.device!.toJSON())
    }
}
