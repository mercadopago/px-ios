//
//  TermsAndConditionsViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class TermsAndConditionsViewCell: UITableViewCell, UITextViewDelegate {

    private static let ROW_HEIGHT = CGFloat(44)

    @IBOutlet weak var termsAndConditionsText: MPTextView!

    var delegate: TermsAndConditionsDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.termsAndConditionsText.delegate = self

        self.termsAndConditionsText.isUserInteractionEnabled = true

        self.termsAndConditionsText.attributedText = TermsAndConditionsViewCell.getTyCText()

        let URLAttribute = [NSFontAttributeName: UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: 12) ?? UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.primaryColor()]

        self.termsAndConditionsText.linkTextAttributes = URLAttribute

        let separatorLine = ViewUtils.getTableCellSeparatorLineView(0, y: TermsAndConditionsViewCell.getCellHeight() - 1, width: UIScreen.main.bounds.width, height: 1)
        self.addSubview(separatorLine)

    }

    private static func getTermsAndConditionsTextView() -> MPTextView {
        let textView = MPTextView()
        textView.isUserInteractionEnabled = true

        textView.attributedText = getTyCText()
        return textView
    }

    private static func getTyCText() -> NSMutableAttributedString {

        let termsAndConditionsText = "Al pagar, afirmo que soy mayor de edad y acepto los Términos y Condiciones de Mercado Pago".localized
        let normalAttributes: [String:AnyObject] = [NSFontAttributeName: Utils.getFont(size: 12), NSForegroundColorAttributeName: UIColor.px_grayLight()]

        let mutableAttributedString = NSMutableAttributedString(string: termsAndConditionsText, attributes: normalAttributes)
        let tycLinkRange = (termsAndConditionsText as NSString).range(of: "Términos y Condiciones".localized)

        mutableAttributedString.addAttribute(NSLinkAttributeName, value: MercadoPagoContext.getTermsAndConditionsSite(), range: tycLinkRange)

        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineSpacing = CGFloat(6)

        mutableAttributedString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, mutableAttributedString.length))
        return mutableAttributedString
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        self.delegate?.openTermsAndConditions("Términos y Condiciones".localized, url : URL)
        return false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    static public func getCellHeight() -> CGFloat {
        let textView = getTermsAndConditionsTextView()
        let textViewHeight = textView.contentSize.height
        return TermsAndConditionsViewCell.ROW_HEIGHT + textViewHeight
    }

}

protocol TermsAndConditionsDelegate {

    func openTermsAndConditions(_ title: String, url: URL)
}
