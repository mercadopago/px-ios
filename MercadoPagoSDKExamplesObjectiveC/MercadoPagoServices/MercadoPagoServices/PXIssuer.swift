//
//  PXIssuer.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXIssuer: NSObject, Codable {
    open var _id: String! // TODO: Cambiar
    open var name: String!

    init(id: String, name: String) {
        self._id = id
        self.name = name
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

    open class func fromJSON(data: Data) throws -> PXIssuer {
        return try JSONDecoder().decode(PXIssuer.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXIssuer] {
        return try JSONDecoder().decode([PXIssuer].self, from: data)
    }

}
