//
//  PXIssuer.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXIssuer: NSObject, Codable {
    open var id: String!
    open var name: String!

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    enum PXIssuerKeys: String, CodingKey {
        case name = "name"
        case id = "id"
    }

//    required public convenience init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: PXIssuerKeys.self)
//        let name: String = try container.decode(String.self, forKey: .name)
//        let id: String = try container.decode(String.self, forKey: .id)
//
//        self.init(id: id, name: name)
//    }

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open class func fromJSON(data: Data) throws -> PXIssuer {
        return try JSONDecoder().decode(PXIssuer.self, from: data)
    }

}
