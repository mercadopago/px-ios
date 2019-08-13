//
//  PXInitDiscountParamsConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 11/08/2019.
//

import Foundation

struct PXInitDiscountParamsConfiguration: Codable {

    let productId: String
    let labels: [String]

    public enum DiscountParamsConfigCodingKeys: String, CodingKey {
        case productId = "product_id"
        case labels
    }
}
