//
//  PXIdentification.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class PXIdentification: NSObject, Codable {

    open var number: String?
    open var type: String?

    public init(number: String?, type: String?) {
        self.type = type
        self.number = number
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

    open class func fromJSON(data: Data) throws -> PXIdentification {
        return try JSONDecoder().decode(PXIdentification.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXIdentification] {
        return try JSONDecoder().decode([PXIdentification].self, from: data)
    }

}
