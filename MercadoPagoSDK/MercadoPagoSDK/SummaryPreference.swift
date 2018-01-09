//
//  SummaryPreference.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/6/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
extension ReviewScreenPreference {

    public func addSummaryProductDetail(amount: Double) {
        self.addDetail(detail: SummaryItemDetail(amount: amount), type: SummaryType.PRODUCT)
    }
    public func addSummaryDiscountDetail(amount: Double) {
        self.addDetail(detail: SummaryItemDetail(amount: amount), type: SummaryType.DISCOUNT)
    }
    public func addSummaryChargeDetail(amount: Double) {
        self.addDetail(detail: SummaryItemDetail(amount: amount), type: SummaryType.CHARGE)
    }
    public func addSummaryTaxesDetail(amount: Double) {
        self.addDetail(detail: SummaryItemDetail(amount: amount), type: SummaryType.TAXES)
    }
    public func addSummaryShippingDetail(amount: Double) {
        self.addDetail(detail: SummaryItemDetail(amount: amount), type: SummaryType.SHIPPING)
    }
    public func addSummaryArrearsDetail(amount: Double) {
        self.addDetail(detail: SummaryItemDetail(amount: amount), type: SummaryType.ARREARS)
    }
    public func setSummaryProductTitle(productTitle: String) {
        self.updateTitle(type: SummaryType.PRODUCT, title: productTitle)
    }
    public func setSummaryDisclaimer(disclaimerText: String, disclaimerColor: UIColor = UIColor.px_grayDark()) {
        self.disclaimer = disclaimerText
        self.disclaimerColor = disclaimerColor
    }
    func updateTitle(type: SummaryType, title: String) {
        if self.details[type] != nil {
            self.details[type]?.title = title
        } else {
            self.details[type] = SummaryDetail(title: title, detail: nil)
        }
        if type == SummaryType.DISCOUNT {
            self.details[type]?.titleColor = UIColor.mpGreenishTeal()
            self.details[type]?.amountColor = UIColor.mpGreenishTeal()
        }
    }
    public func getOneWordDescription(oneWordDescription: String) -> String {
        if oneWordDescription.characters.count <= 0 {
            return ""
        }
        if let firstWord = oneWordDescription.components(separatedBy: " ").first {
            return firstWord
        } else {
            return oneWordDescription
        }

    }

    func addDetail(detail: SummaryItemDetail, type: SummaryType) {
        if self.details[type] != nil {
            self.details[type]?.details.append(detail)
        } else {
            guard let title = self.summaryTitles[type] else {
                self.details[type] = SummaryDetail(title: "", detail: detail)
                return
            }
            self.details[type] = SummaryDetail(title: title, detail: detail)
        }
        if type == SummaryType.DISCOUNT {
            self.details[type]?.titleColor = UIColor.mpGreenishTeal()
            self.details[type]?.amountColor = UIColor.mpGreenishTeal()
        }
    }

    func getSummaryTotalAmount() -> Double {
        var totalAmount = 0.0
        guard let productDetail = details[SummaryType.PRODUCT] else {
            return 0.0
        }
        if productDetail.getTotalAmount() <= 0 {
            return 0.0
        }
        for summaryType in details.keys {
            if let detailAmount = details[summaryType]?.getTotalAmount() {
                if summaryType == SummaryType.DISCOUNT {
                    totalAmount = totalAmount - detailAmount
                } else {
                    totalAmount = totalAmount + detailAmount
                }
            }
        }
        return totalAmount
    }

}
