//
//  SummaryComponent.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/7/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class SummaryComponent: UIView, PXComponent {
    let SMALL_MARGIN_HEIGHT: CGFloat = 8.0
    let MEDIUM_MARGIN_HEIGHT: CGFloat = 12.0
    let LARGE_MARGIN_HEIGHT: CGFloat = 28.0
    let HORIZONTAL_MARGIN: CGFloat = 24.0
    let DETAILS_HEIGHT: CGFloat = 18.0
    let TOTAL_HEIGHT: CGFloat = 24.0
    let PAYER_COST_HEIGHT: CGFloat = 20.0
    let DISCLAIMER_HEIGHT: CGFloat = 20.0
    let DISCLAIMER_FONT_SIZE: CGFloat = 12.0
    static let TOTAL_TITLE = "Total".localized
    var requiredHeight: CGFloat = 0.0
    let summary: Summary!

    init(frame: CGRect, summary: Summary, paymentData: PaymentData, totalAmount: Double) {
        self.summary = summary
        super.init(frame: frame)
        self.addDetailsViews(typeDetailDictionary: summary.details)
        var payerCost = paymentData.payerCost
        if payerCost != nil && (payerCost?.installments)! > 1 {
            self.addMediumMargin()
            self.addLine()
            self.addMediumMargin()
            self.addPayerCost(payerCost: payerCost!)
            self.addMediumMargin()
            self.addLine()
            self.addMediumMargin()
            self.addTotalView(totalAmount: (payerCost?.totalAmount)!)
        }else {
            var amount = totalAmount
            if let discount = paymentData.discount {
                amount = discount.newAmount()
            }
            self.addMediumMargin()
            if shouldAddTotal() {
                self.addLine()
                self.addMediumMargin()
                self.addTotalView(totalAmount: amount)
            }
        }
        self.addLargeMargin()
        if let disclaimer = summary.disclaimer {
            self.addDisclaimerView(text: disclaimer, color: summary.disclaimerColor)
            self.addLargeMargin()
        }

    }

    func shouldAddTotal() -> Bool {
        return self.summary.details.count > 1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func getHeight() -> CGFloat {
        return requiredHeight
    }
    func getWeight() -> CGFloat {
        return self.frame.size.width
    }

    func addDetailsViews(typeDetailDictionary: [SummaryType:SummaryDetail]) {
        for type in iterateEnum(SummaryType.self) {
            let frame = CGRect(x: 0.0, y: requiredHeight, width: self.frame.size.width, height: DETAILS_HEIGHT)
            if let detail = typeDetailDictionary[type] {
                var value: Double = detail.getTotalAmount()
                if type == SummaryType.DISCOUNT {
                    value = value * (-1)
                }
                let titleValueView = TitleValueView(frame: frame, titleText: detail.title, valueDouble: value, colorTitle: detail.titleColor, colorValue: detail.amountColor, valueEnable: true)
                self.addSmallMargin()
                self.addSubview(titleValueView)
                requiredHeight = requiredHeight + titleValueView.getHeight()
            }
        }
    }

    func addTotalView(totalAmount: Double) {
        let frame = CGRect(x: 0.0, y: requiredHeight, width: self.frame.size.width, height: DETAILS_HEIGHT)
        let titleValueView = TitleValueView(frame: frame, titleText: SummaryComponent.TOTAL_TITLE, valueDouble: totalAmount, valueEnable: true)
        requiredHeight = requiredHeight + titleValueView.getHeight()
        self.addSubview(titleValueView)
    }
    func addPayerCost(payerCost: PayerCost) {
        let payerCostView = PayerCostView(frame: CGRect(x: 0, y: requiredHeight, width: self.frame.size.width, height: PAYER_COST_HEIGHT), payerCost: payerCost)
        self.addSubview(payerCostView)
        payerCostView.frame =  CGRect(x: 0, y: requiredHeight, width: self.frame.size.width, height: payerCostView.getHeight())
        requiredHeight = requiredHeight + payerCostView.getHeight()
    }
    func addDisclaimerView(text: String, color: UIColor) {
        let disclaimerView = DisclaimerView(frame: CGRect(x: 0, y: requiredHeight, width: self.frame.size.width, height: DISCLAIMER_HEIGHT), disclaimerText: text, colorText: color, disclaimerFontSize: DISCLAIMER_FONT_SIZE)
        self.addSubview(disclaimerView)
        self.requiredHeight = self.requiredHeight + disclaimerView.getHeight()
    }

    func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
        var i = 0
        return AnyIterator {
            let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
            if next.hashValue != i { return nil }
            i += 1
            return next
        }
    }

    func addSmallMargin() {
        self.addMargin(height: SMALL_MARGIN_HEIGHT)
    }
    func addMediumMargin() {
        self.addMargin(height: MEDIUM_MARGIN_HEIGHT)
    }
    func addLargeMargin() {
        self.addMargin(height: LARGE_MARGIN_HEIGHT)
    }
    func addMargin(height: CGFloat) {
        self.requiredHeight = self.requiredHeight + height
    }
    func addLine() {
        self.addLine(y: self.requiredHeight, horizontalMargin: HORIZONTAL_MARGIN, width: self.frame.size.width - 2 * HORIZONTAL_MARGIN, height: 1)
        self.requiredHeight = self.requiredHeight + 1.0
    }
}
