//
//  PXSite.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXSite: NSObject, Codable {

    open var id: String!
    open var currencyId: String!

    public init(id: String, currencyId: String) {
        self.id = id
        self.currencyId = currencyId
    }

    public enum PXSiteKeys: String, CodingKey {
        case id
        case currencyId = "currency_id"
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXSiteKeys.self)
        let id: String = try container.decode(String.self, forKey: .id)
        let currencyId: String = try container.decode(String.self, forKey: .currencyId)

        self.init(id: id, currencyId: currencyId)
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

    open class func fromJSON(data: Data) throws -> PXSite {
        return try JSONDecoder().decode(PXSite.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXSite] {
        return try JSONDecoder().decode([PXSite].self, from: data)
    }

}
