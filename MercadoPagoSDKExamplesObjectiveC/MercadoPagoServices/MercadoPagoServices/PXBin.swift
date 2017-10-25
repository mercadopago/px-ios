//
//  PXBin.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXBin: NSObject, Codable {

    open var exclusionPattern: String!
    open var installmentPattern: String!
    open var pattern: String!

    init(exclusionPattern: String, installmentPattern: String, pattern: String) {
        self.exclusionPattern = exclusionPattern
        self.installmentPattern = installmentPattern
        self.pattern = pattern
    }

    public enum PXBinKeys: String, CodingKey {
        case exclusionPattern = "exclusion_pattern"
        case installmentPattern = "installment_pattern"
        case pattern
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXBinKeys.self)
        let exclusionPattern: String = try container.decode(String.self, forKey: .exclusionPattern)
        let installmentPattern: String = try container.decode(String.self, forKey: .installmentPattern)
        let pattern: String = try container.decode(String.self, forKey: .pattern)

        self.init(exclusionPattern: exclusionPattern, installmentPattern: installmentPattern, pattern: pattern)
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

    open class func fromJSON(data: Data) throws -> PXBin {
        return try JSONDecoder().decode(PXBin.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXBin] {
        return try JSONDecoder().decode([PXBin].self, from: data)
    }

}
