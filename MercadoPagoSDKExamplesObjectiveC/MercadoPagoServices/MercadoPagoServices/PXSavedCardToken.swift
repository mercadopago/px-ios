//
//  PXSavedCardToken.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXSavedCardToken: NSObject, Codable {

    open var cardId: String!
    open var securityCode: String!
    open var device: PXDevice!

    public enum PXSavedCardTokenKeys: String, CodingKey {
        case cardId = "card_id"
        case securityCode = "security_code"
        case device
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXSavedCardTokenKeys.self)
        try container.encodeIfPresent(self.cardId, forKey: .cardId)
        try container.encodeIfPresent(self.securityCode, forKey: .securityCode)
        try container.encodeIfPresent(self.device, forKey: .device)
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

    open class func fromJSON(data: Data) throws -> PXSavedCardToken {
        return try JSONDecoder().decode(PXSavedCardToken.self, from: data)
    }
}
