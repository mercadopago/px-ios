//
//  PXPicture.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPicture: NSObject, Codable {
    open var id: String!
    open var size: String!
    open var url: String!
    open var secureUrl: String!

    public init(id: String, size: String, url: String, secureUrl: String) {
        self.id = id
        self.size = size
        self.url = url
        self.secureUrl = secureUrl
    }

    public enum PXPictureKeys: String, CodingKey {
        case id
        case size
        case url
        case secureUrl = "secure_url"
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXPictureKeys.self)
        let id: String = try container.decode(String.self, forKey: .id)
        let size: String = try container.decode(String.self, forKey: .size)
        let url: String = try container.decode(String.self, forKey: .url)
        let secureUrl: String = try container.decode(String.self, forKey: .secureUrl)

        self.init(id: id, size: size, url: url, secureUrl: secureUrl)
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

    open class func fromJSON(data: Data) throws -> PXPicture {
        return try JSONDecoder().decode(PXPicture.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXPicture] {
        return try JSONDecoder().decode([PXPicture].self, from: data)
    }
}
