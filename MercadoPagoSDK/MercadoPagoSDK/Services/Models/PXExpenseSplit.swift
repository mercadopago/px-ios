//
//  PXExpenseSplit.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 22/06/2020.
//

import Foundation

struct PXExpenseSplit: Codable {
    let title: PXText
    let action: PXRemoteAction
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case title
        case action
        case imageUrl = "image_url"
    }
}
