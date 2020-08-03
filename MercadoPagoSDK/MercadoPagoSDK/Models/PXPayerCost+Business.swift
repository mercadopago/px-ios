//
//  PXPayerCost+Business.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 26/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension PXPayerCost: Cellable {
    var objectType: ObjectTypes {
        get {
            return ObjectTypes.payerCost
        }
        set {
            self.objectType = ObjectTypes.payerCost
        }
    }

    func hasInstallmentsRate() -> Bool {
        return installmentRate > 0.0 && installments > 1
    }

    func hasCFTValue() -> Bool {
        return !String.isNullOrEmpty(getCFT())
    }

    private func getLabels() -> [String: String] {
        let prefixes: [String] = ["CFT", "TEA"]
        var labelsDictionary: [String: String] = [:]
        _ = labels.filter { prefixes.contains(where: $0.hasPrefix) }.flatMap { $0.components(separatedBy: "|") }.map { (label) -> String in
            let array = label.components(separatedBy: "_")
            if array.count == 2 {
                labelsDictionary[array[0]] = array[1]
            }
            return label
        }
        return labelsDictionary
    }

    func getCFT(separator: String = "") -> String? {
        let cftString = getLabels().compactMap { (key, value) -> String? in
            if key.hasPrefix("CFT") {
                return "\(key)\(separator) \(value)"
            }
            return nil
        }.joined()
        return cftString
    }

    func getTEAValue() -> String? {
        return getLabels()["TEA"]
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
