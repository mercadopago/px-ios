//
//  CardIssuerTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class CardIssuerTest: BaseTest {
    
    func testInit(){
        let cardIssuer = CardIssuer(_id: "id", name: "name", labels: ["label1", "label2"])
        XCTAssertEqual(cardIssuer._id, "id")
        XCTAssertEqual(cardIssuer.name, "name")
        XCTAssertEqual(cardIssuer.labels, ["label1", "label2"])
    }
    
    
}
