//
//  PXOneTapOfflineCard.swift
//  MercadoPagoSDKV4
//
//  Created by Vinicius De Andrade Silva on 18/05/21.
//

import UIKit

open class PXOneTapOfflineCard: NSObject, Codable {
    
    open var displayInfo: PXCardDisplayInfoDto?
    
    public enum CodingKeys: String, CodingKey {
        case displayInfo = "display_info"
    }
}
