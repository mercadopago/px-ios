//
//  PXOneTapSummaryRowData.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 26/08/2019.
//

import UIKit

class PXOneTapSummaryRowData: Equatable {
    let title: String
    let value: String
    let highlightedColor: UIColor
    let alpha: CGFloat
    let isTotal: Bool
    let image: UIImage?
    let type: PXOneTapSummaryRowView.RowType?
    let discountOverview: PXDiscountOverview?
    let briefColor: UIColor?
    var splitMoney = false

    init(title: String, value: String, highlightedColor: UIColor, alpha: CGFloat, isTotal: Bool, image: UIImage?, type: PXOneTapSummaryRowView.RowType?, discountOverview: PXDiscountOverview? = nil, briefColor: UIColor? = nil) {
        self.title = title
        self.value = value
        self.highlightedColor = highlightedColor
        self.alpha = alpha
        self.isTotal = isTotal
        self.image = image
        self.type = type
        self.discountOverview = discountOverview
        self.briefColor = briefColor
    }

    static func == (lhs: PXOneTapSummaryRowData, rhs: PXOneTapSummaryRowData) -> Bool {
        return lhs.title == rhs.title && lhs.value == rhs.value && lhs.highlightedColor == rhs.highlightedColor && lhs.alpha == rhs.alpha && lhs.isTotal == rhs.isTotal && lhs.image == rhs.image && lhs.type == rhs.type && lhs.discountOverview == rhs.discountOverview && lhs.briefColor == rhs.briefColor && lhs.splitMoney == rhs.splitMoney
    }
}

// MARK: PXDiscountOverview
extension PXOneTapSummaryRowData {
    func rowHasBrief() -> Bool {
        guard let brief = discountOverview?.brief, !brief.isEmpty else { return false }
        return UIDevice.isSmallDevice() && splitMoney ? false : true
    }

    func rowHasInfoIcon() -> Bool {
        guard let url = discountOverview?.url, !url.isEmpty else { return false }
        return true
    }

    func getAmountText() -> NSAttributedString? {
        return discountOverview?.amount.getAttributedString(fontSize: PXLayout.XXS_FONT, textColor: highlightedColor, backgroundColor: .clear)
    }

    func getDescriptionText() -> NSAttributedString? {
        guard let description = discountOverview?.description else { return nil }
        return getAttributedText(array: description, textColor: highlightedColor, fontSize: PXLayout.XXS_FONT)
    }

    func getBriefText() -> NSAttributedString? {
        guard let brief = discountOverview?.brief else { return nil }
        return getAttributedText(array: brief, textColor: briefColor, fontSize: PXLayout.XXXS_FONT)
    }

    func getIconUrl() -> String? {
        return discountOverview?.url
    }

    private func getAttributedText(array: [PXText], textColor: UIColor?, fontSize: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        for (index, text) in array.enumerated() {
            if let attrString = text.getAttributedString(fontSize: fontSize, textColor: textColor, backgroundColor: .clear) {
                index == 0 ? attributedString.append(attrString) : attributedString.appendWithSpace(attrString)
            }
        }
        return attributedString
    }
}
