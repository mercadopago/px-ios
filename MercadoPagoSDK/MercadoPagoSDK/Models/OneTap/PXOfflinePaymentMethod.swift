//
//  PXOfflinePaymentMethod.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 18/12/2019.
//

import Foundation

public struct PXOfflinePaymentMethod: Codable {
    let id: String
    let name: PXText?
    let description: PXText?
    let imageUrl: String?
    let hasAdditionalInfoNeeded: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageUrl = "image_url"
        case hasAdditionalInfoNeeded = "has_additional_info_needed"
    }
}
