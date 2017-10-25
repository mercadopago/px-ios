//
//  PXSecurityCode.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXSecurityCode: NSObject, Codable {

    open var cardLocation: String!
    open var mode: String?
    open var length: Int!

    init(cardLocation: String, mode: String?, length: Int) {
        self.cardLocation = cardLocation
        self.mode = mode
        self.length = length
    }

    public enum PXSecurityCodeKeys: String, CodingKey {
        case cardLocation = "card_location"
        case mode
        case length
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXSecurityCodeKeys.self)
        let cardLocation: String = try container.decode(String.self, forKey: .cardLocation)
        let mode: String? = try container.decodeIfPresent(String.self, forKey: .mode)
        let length: Int = try container.decode(Int.self, forKey: .length)

        self.init(cardLocation: cardLocation, mode: mode, length: length)
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

    open class func fromJSON(data: Data) throws -> PXSecurityCode {
        return try JSONDecoder().decode(PXSecurityCode.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXSecurityCode] {
        return try JSONDecoder().decode([PXSecurityCode].self, from: data)
    }

}
