//
//  PXAmountInfo.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXAmountInfo: NSObject, Codable {

    open var amount: Double!
    open var currency: PXCurrency!

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open class func fromJSON(data: Data) throws -> PXAmountInfo {
        return try JSONDecoder().decode(PXAmountInfo.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXAmountInfo] {
        return try JSONDecoder().decode([PXAmountInfo].self, from: data)
    }

}
