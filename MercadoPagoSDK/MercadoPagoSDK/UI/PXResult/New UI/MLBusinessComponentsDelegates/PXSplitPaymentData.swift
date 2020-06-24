//
//  PXSplitPaymentData.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 22/06/2020.
//

import Foundation
import MLBusinessComponents

class PXSplitPaymentData: NSObject {

    let splitPaymentData: PXExpenseSplit

    init(splitPaymentData: PXExpenseSplit) {
        self.splitPaymentData = splitPaymentData
    }
}

extension PXSplitPaymentData: MLBusinessSplitPaymentData {
    func getTitle() -> String {
        return splitPaymentData.title.message ?? " "
    }

    func getTitleColor() -> String {
        return splitPaymentData.title.textColor ?? ""
    }

    func getTitleBackgroundColor() -> String {
        return splitPaymentData.title.backgroundColor ?? ""
    }

    func getTitleWeight() -> String {
        return splitPaymentData.title.weight ?? ""
    }

    func getImageUrl() -> String {
        return splitPaymentData.icon
    }

    func getAffordanceText() -> String {
        return splitPaymentData.action.label
    }
}
