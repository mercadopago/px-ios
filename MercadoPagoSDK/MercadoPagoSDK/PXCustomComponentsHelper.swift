//
//  PXCustomComponentsHelper.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

/** :nodoc: */
extension PXResultViewModel {
    open func buildTopCustomComponent() -> PXCustomComponentizable? {
        if let customComponent = preference.getApprovedTopCustomComponent(), self.paymentResult.isApproved() {
            return PXCustomComponentContainer(withComponent: customComponent)
        } else {
            return nil
        }
    }

    open func buildBottomCustomComponent() -> PXCustomComponentizable? {
        if let customComponent = preference.getApprovedBottomCustomComponent(), self.paymentResult.isApproved() {
            return PXCustomComponentContainer(withComponent: customComponent)
        } else {
            return nil
        }
    }
}
