//
//  PXPayerCost+Business.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 26/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension PXPayerCost {

    func hasInstallmentsRate() -> Bool {
        return installmentRate > 0.0 && installments > 1
    }

    func getPayerCostForTracking(isDigitalCurrency: Bool = false) -> [String: Any] {
        var installmentDic: [String: Any] = [:]
        installmentDic["quantity"] = installments
        installmentDic["installment_amount"] = installmentAmount
        installmentDic["interest_rate"] = installmentRate
        if hasInstallmentsRate() || isDigitalCurrency {
            installmentDic["visible_total_price"] = totalAmount
        }
        return installmentDic
    }
}
