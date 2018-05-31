//
//  PXDiscountTermsAndConditionView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 28/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

class PXDiscountTermsAndConditionView: PXTermsAndConditionView {

    override init() {
        super.init()
        self.SCREEN_NAME = "DISCOUNT_TERMS_AND_CONDITIONS"
        self.SCREEN_TITLE = "Términos y Condiciones"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func getTyCText() -> NSMutableAttributedString {
        let termsAndConditionsText = "Descuento exclusivo de Mercado Libre.\nVer condiciones".localized
        let highlightedText = "Ver condiciones".localized

        let normalAttributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: Utils.getFont(size: 12), NSAttributedStringKey.foregroundColor: ThemeManager.shared.labelTintColor()]

        let mutableAttributedString = NSMutableAttributedString(string: termsAndConditionsText, attributes: normalAttributes)
        let tycLinkRange = (termsAndConditionsText as NSString).range(of: highlightedText)

        mutableAttributedString.addAttribute(NSAttributedStringKey.link, value: "https://api.mercadolibre.com/campaigns/12344/terms_and_conditions?format_type=html", range: tycLinkRange)

        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineSpacing = CGFloat(3)

        mutableAttributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: NSRange(location: 0, length: mutableAttributedString.length))
        return mutableAttributedString
    }

    override func handleTap(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: "https://api.mercadolibre.com/campaigns/12344/terms_and_conditions?format_type=html") {
            delegate?.shouldOpenTermsCondition(SCREEN_TITLE.localized, screenName: SCREEN_NAME, url: url)
        }
    }
}
