//
//  PXDiscountTermsAndConditionView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 28/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoPXTrackingV4

final class PXDiscountTermsAndConditionView: PXTermsAndConditionView {

    private var amountHelper: PXAmountHelper

    init(amountHelper: PXAmountHelper, shouldAddMargins: Bool = true) {
        self.amountHelper = amountHelper
        super.init(shouldAddMargins: shouldAddMargins)
        self.SCREEN_NAME = TrackingUtil.ScreenId.DISCOUNT_TERM_CONDITION
        self.SCREEN_TITLE = "Términos y Condiciones"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func getTyCText() -> NSMutableAttributedString {
        let termsAndConditionsText = "review_discount_terms_and_conditions".PXLocalized
        let highlightedText = "review_discount_terms_and_conditions_link".PXLocalized

        let normalAttributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: Utils.getFont(size: PXLayout.XXXS_FONT), NSAttributedStringKey.foregroundColor: ThemeManager.shared.labelTintColor()]

        let mutableAttributedString = NSMutableAttributedString(string: termsAndConditionsText, attributes: normalAttributes)
        let tycLinkRange = (termsAndConditionsText as NSString).range(of: highlightedText)

        mutableAttributedString.addAttribute(NSAttributedStringKey.link, value: self.getTyCURL(), range: tycLinkRange)

        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineSpacing = CGFloat(3)

        mutableAttributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: NSRange(location: 0, length: mutableAttributedString.length))
        return mutableAttributedString
    }

    override func handleTap(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: self.getTyCURL()) {
            delegate?.shouldOpenTermsCondition(SCREEN_TITLE.localized, screenName: SCREEN_NAME, url: url)
        }
    }

    func getTyCURL() -> String {
        if let campaignID = self.amountHelper.campaign?.id {
            return "https://api.mercadolibre.com/campaigns/\(campaignID)/terms_and_conditions?format_type=html"
        }
        return ""
    }
}
