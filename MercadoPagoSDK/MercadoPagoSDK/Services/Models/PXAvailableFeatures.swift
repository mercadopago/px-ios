//
//  PXAvailableFeatures.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 31/10/2019.
//

import Foundation

struct PXAvailableFeatures: Decodable {
    let id: String
    let enabled: Bool
}

// MARK: Tracking
extension PXAvailableFeatures {
    func getDictionary() -> [String: Any] {
        var dic = [String: Any]()
        dic["id"] = id
        dic["enabled"] = enabled
        return dic
    }
}
