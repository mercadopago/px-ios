//
//  PXCard.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXCard: NSObject {
    open var cardHolder: PXCardHolder!
    open var customerId: String!
    open var dateCreated: Date!
    open var lastUpdated: Date!
    open var expirationMonth: Int!
    open var expirationYear: Int!
    open var firstSixDigits: String!
    open var id: String!
    open var issuer: PXIssuer!
    open var lastFourDigits: String!
    open var paymentMethod: PXPaymentMethod!
    open var securityCode: PXSecurityCode!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["":""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXCard {
        return PXCard()
    }
}
