//
//  PXDiscountConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 10/8/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoServicesV4

internal typealias PXDiscountConfigurationType = (discount: PXDiscount?, campaign: PXCampaign?, isNotAvailable: Bool)

@objcMembers
open class PXDiscountConfiguration: NSObject {
    private var discount: PXDiscount?
    private var campaign: PXCampaign?
    private var isNotAvailable: Bool = false

    internal override init() {
        self.discount = nil
        self.campaign = nil
        isNotAvailable = true
    }

    public init(discount: PXDiscount, campaign: PXCampaign) {
        self.discount = discount
        self.campaign = campaign
    }

    public static func initForNotAvailableDiscount() -> PXDiscountConfiguration {
        return PXDiscountConfiguration()
    }
}

// MARK: - Internals
extension PXDiscountConfiguration {
    internal func getDiscountConfiguration() -> PXDiscountConfigurationType {
        return (discount, campaign, isNotAvailable)
    }
}
