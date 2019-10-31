//
//  PXVariant.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 31/10/2019.
//

import Foundation

struct PXVariant: Decodable {
    let id: String
    let name: String
    let availableFeatures: [PXAvailableFeatures]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case availableFeatures = "available_features"
    }
}

// MARK: Tracking
extension PXVariant {
    func getDictionary() -> [String: Any] {
        var dic = [String: Any]()
        dic["id"] = id
        dic["name"] = name

        var availableFeaturesDics = [Any]()
        for feature in availableFeatures {
            availableFeaturesDics.append(feature.getDictionary())
        }
        dic["available_features"] = availableFeaturesDics
        
        return dic
    }
}
