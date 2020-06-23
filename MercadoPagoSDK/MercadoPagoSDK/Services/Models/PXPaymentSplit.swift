//
//  PXPaymentSplit.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 22/06/2020.
//

import Foundation

struct PXPaymentSplit: Codable {
    let title: PXText
    let action: PXRemoteAction
    let icon: String

    enum CodingKeys: String, CodingKey {
        case title
        case action
        case icon
    }
}
