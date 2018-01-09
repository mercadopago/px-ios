//
//  PXCustomComponentsHelper.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension PXResultViewModel {
    open func buildTopCustomComponent() -> PXComponentizable? {
        if let customComponent = preference.getApprovedTopCustomComponent(), self.paymentResult.isApproved() {
            return PXCustomComponentContainer(withComponent: customComponent)
        } else {
            return nil
        }
    }

    open func buildBottomCustomComponent() -> PXComponentizable? {
        if let customComponent = preference.getApprovedBottomCustomComponent(), self.paymentResult.isApproved() {
            return PXCustomComponentContainer(withComponent: customComponent)
        } else {
            return nil
        }
    }
}
