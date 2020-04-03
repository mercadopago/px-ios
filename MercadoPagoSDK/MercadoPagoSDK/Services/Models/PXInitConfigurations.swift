//
//  PXInitConfigurations.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 27/02/2020.
//

import Foundation

final class PXInitConfigurations: Decodable {
    let ESCBlacklistedStatus: [String]?

    enum CodingKeys: String, CodingKey {
        case ESCBlacklistedStatus = "esc_blacklisted_status"
    }
}
