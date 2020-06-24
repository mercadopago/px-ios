//
//  PXExpenseSplitData.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 22/06/2020.
//

import Foundation
import MLBusinessComponents

class PXExpenseSplitData: NSObject {

    let splitPaymentData: PXExpenseSplit

    init(splitPaymentData: PXExpenseSplit) {
        self.splitPaymentData = splitPaymentData
    }
}

extension PXExpenseSplitData: MLBusinessSplitPaymentData {
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
        return splitPaymentData.imageUrl
    }

    func getAffordanceText() -> String {
        return splitPaymentData.action.label
    }
}
