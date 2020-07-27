//
//  PXCheckoutPreference+AdditionalInfo.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 4/8/19.
//

import Foundation

internal extension PXCheckoutPreference {
    func populateAdditionalInfoModel() {
        if let additionalInfo = additionalInfo,
            let data = additionalInfo.data(using: .utf8) {
            do {
                pxAdditionalInfo = try PXAdditionalInfo.fromJSON(data: data)
            } catch {
                printDebug(error)
            }
        }
    }

    func getAdditionalInfoModel() -> PXAdditionalInfo? {
        return pxAdditionalInfo
    }
}
