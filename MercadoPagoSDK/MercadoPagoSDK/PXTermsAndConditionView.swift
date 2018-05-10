//
//  PXTermsAndConditionView.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 5/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

protocol PXTermsAndConditionViewDelegate: NSObjectProtocol {
    func shouldOpenTermsCondition(_ title: String, screenName: String, url: URL)
}

final class PXTermsAndConditionView: PXComponentView {

    fileprivate let SCREEN_NAME = "TERMS_AND_CONDITIONS"
    fileprivate let SCREEN_TITLE = "Términos y Condiciones"

    fileprivate let termsAndConditionsText: MPTextView = MPTextView()

    weak var delegate: PXTermsAndConditionViewDelegate?

    override init() {

        super.init()

        translatesAutoresizingMaskIntoConstraints = false

        termsAndConditionsText.isUserInteractionEnabled = true
        termsAndConditionsText.isEditable = false
        termsAndConditionsText.delegate = self
        termsAndConditionsText.translatesAutoresizingMaskIntoConstraints = false
        termsAndConditionsText.attributedText = getTyCText()
        termsAndConditionsText.isUserInteractionEnabled = false

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        self.addGestureRecognizer(tap)

        addSubview(termsAndConditionsText)

        let URLAttribute: [String: Any] = [NSAttributedStringKey.font.rawValue: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 12) ?? UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor.rawValue: ThemeManager.shared.secondaryColor()]

        termsAndConditionsText.linkTextAttributes = URLAttribute

        let PERCENT_WIDTH: CGFloat = 90.0
        PXLayout.matchWidth(ofView: termsAndConditionsText, toView: self, withPercentage: PERCENT_WIDTH).isActive = true

        PXLayout.centerHorizontally(view: termsAndConditionsText).isActive = true

        let dynamicHeight: CGFloat = termsAndConditionsText.contentSize.height + PXLayout.S_MARGIN

        PXLayout.setHeight(owner: termsAndConditionsText, height: dynamicHeight).isActive = true

        PXLayout.pinTop(view: termsAndConditionsText, withMargin: PXLayout.S_MARGIN).isActive = true

        PXLayout.pinBottom(view: termsAndConditionsText, withMargin: PXLayout.S_MARGIN).isActive = true

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PXTermsAndConditionView {

    fileprivate func getTyCText() -> NSMutableAttributedString {

        let termsAndConditionsText = "Al pagar, afirmo que soy mayor de edad y acepto los Términos y Condiciones de Mercado Pago".localized

        let normalAttributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: Utils.getFont(size: 12), NSAttributedStringKey.foregroundColor: ThemeManager.shared.labelTintColor()]

        let mutableAttributedString = NSMutableAttributedString(string: termsAndConditionsText, attributes: normalAttributes)
        let tycLinkRange = (termsAndConditionsText as NSString).range(of: SCREEN_TITLE.localized)

        mutableAttributedString.addAttribute(NSAttributedStringKey.link, value: MercadoPagoContext.getTermsAndConditionsSite(), range: tycLinkRange)

        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineSpacing = CGFloat(3)

        mutableAttributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: NSRange(location: 0, length: mutableAttributedString.length))
        return mutableAttributedString
    }
}

extension PXTermsAndConditionView: UITextViewDelegate, UIGestureRecognizerDelegate {

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: MercadoPagoContext.getTermsAndConditionsSite()) {
            delegate?.shouldOpenTermsCondition(SCREEN_TITLE.localized, screenName: SCREEN_NAME, url: url)
        }
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return false
    }
}
