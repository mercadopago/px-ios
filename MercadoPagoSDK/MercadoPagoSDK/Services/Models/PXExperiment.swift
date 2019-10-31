//
//  PXExperiment.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 31/10/2019.
//

import Foundation

struct PXExperiment: Decodable {
    let id: String
    let name: String
    let variant: PXVariant
}

// MARK: Tracking
extension PXExperiment {
    func getDictionary() -> [String: Any] {
        var dic = [String: Any]()
        dic["id"] = id
        dic["name"] = name
        dic["variant"] = variant.getDictionary()
        return dic
    }

    static func getExperimentsForTracking(_ experiments: [PXExperiment]) -> [Any] {
        var dic = [Any]()
        for exp in experiments {
            dic.append(exp.getDictionary())
        }
        return dic
    }
}
