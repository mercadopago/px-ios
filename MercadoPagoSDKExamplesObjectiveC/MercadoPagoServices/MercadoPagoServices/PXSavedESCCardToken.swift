//
//  PXSavedESCCardToken.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXSavedESCCardToken: PXSavedCardToken {
    open var requireEsc: Bool?
    open var esc: String?

    public enum PXSavedESCCardTokenKeys: String, CodingKey {
        case requireEsc = "require_esc"
        case esc
        case cardId = "card_id"
        case securityCode = "security_code"
        case device
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXSavedESCCardTokenKeys.self)
        try container.encodeIfPresent(self.cardId, forKey: .cardId)
        try container.encodeIfPresent(self.securityCode, forKey: .securityCode)
        try container.encodeIfPresent(self.device, forKey: .device)
        try container.encodeIfPresent(self.requireEsc, forKey: .requireEsc)
        try container.encodeIfPresent(self.esc, forKey: .esc)
    }

    open override func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open override func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open override class func fromJSON(data: Data) throws -> PXSavedESCCardToken {
        return try JSONDecoder().decode(PXSavedESCCardToken.self, from: data)
    }

}
