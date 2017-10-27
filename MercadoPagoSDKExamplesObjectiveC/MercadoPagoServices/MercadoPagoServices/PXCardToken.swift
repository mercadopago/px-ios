//
//  PXCardToken.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXCardToken: NSObject, Codable {

    open var cardholder: PXCardHolder!
    open var cardNumber: String!
    open var device: PXDevice!
    open var expirationMonth: Int!
    open var expirationYear: Int!
    open var securityCode: String!

    public enum PXCardTokenKeys: String, CodingKey {
        case cardholder
        case cardNumber = "card_number"
        case device
        case expirationMonth = "expiration_month"
        case expirationYear = "expiration_year"
        case securityCode = "security_code"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXCardTokenKeys.self)
        try container.encodeIfPresent(self.cardholder, forKey: .cardholder)
        try container.encodeIfPresent(self.cardNumber, forKey: .cardNumber)
        try container.encodeIfPresent(self.device, forKey: .device)
        try container.encodeIfPresent(self.expirationMonth, forKey: .expirationMonth)
        try container.encodeIfPresent(self.expirationYear, forKey: .expirationYear)
        try container.encodeIfPresent(self.securityCode, forKey: .securityCode)
    }

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open class func fromJSON(data: Data) throws -> PXCardToken {
        return try JSONDecoder().decode(PXCardToken.self, from: data)
    }
}
