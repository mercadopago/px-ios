//
//  PXOneTapItemRenderer.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 16/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

final class PXOneTapItemRenderer {
    let CONTENT_WIDTH_PERCENT: CGFloat = 86.0
    let CONTENT_TOTAL_WIDTH_PERCENT: CGFloat = 65.0

    // Image
    static let IMAGE_WIDTH: CGFloat = 64.0
    static let IMAGE_HEIGHT: CGFloat = 64.0

    // Fonts
    static let AMOUNT_FONT_SIZE: CGFloat = 44.0
    static let TITLE_FONT_SIZE = PXLayout.S_FONT
    static let AMOUNT_WITHOUT_DISCOUNT_FONT_SIZE = PXLayout.XXS_FONT
    static let DISCOUNT_DESCRIPTION_FONT_SIZE = PXLayout.XXS_FONT

    let arrow: UIImage? = MercadoPago.getImage("oneTapArrow")

    func oneTapRender(_ itemComponent: PXOneTapItemComponent) -> PXOneTapItemContainerView {
        let itemView = PXOneTapItemContainerView()
        itemView.translatesAutoresizingMaskIntoConstraints = false

        let imageObj = buildItemImageUrl(collectorImage: itemComponent.props.collectorImage)

        itemView.itemImage = UIImageView()

        // Item icon
        if let itemImage = itemView.itemImage {
            itemImage.image = imageObj
            itemImage.layer.cornerRadius = PXOneTapItemRenderer.IMAGE_HEIGHT/2
            itemImage.layer.borderWidth = 3
            itemImage.layer.borderColor = ThemeManager.shared.iconBackgroundColor().cgColor
            itemView.addSubviewToBottom(itemImage)
            PXLayout.centerHorizontally(view: itemImage).isActive = true
            PXLayout.setHeight(owner: itemImage, height: PXOneTapItemRenderer.IMAGE_HEIGHT).isActive = true
            PXLayout.setWidth(owner: itemImage, width: PXOneTapItemRenderer.IMAGE_WIDTH).isActive = true
        }

        // Item Title
        itemView.itemTitle = buildTitle(with: itemComponent.props.title, labelColor: ThemeManager.shared.boldLabelTintColor())

        if let itemTitle = itemView.itemTitle {
            itemView.addSubviewToBottom(itemTitle, withMargin: PXLayout.S_MARGIN)
            PXLayout.centerHorizontally(view: itemTitle).isActive = true
            PXLayout.matchWidth(ofView: itemTitle, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
        }

        // Amount without discount
        itemView.amountWithoutDiscount = buildAmountWithoutDiscount(with: itemComponent.props.totalWithoutDiscount, labelColor: ThemeManager.shared.greyColor())

        if let amountWithoutDiscount = itemView.amountWithoutDiscount {
            itemView.addSubviewToBottom(amountWithoutDiscount, withMargin: PXLayout.S_MARGIN)
            PXLayout.centerHorizontally(view: amountWithoutDiscount).isActive = true
            PXLayout.matchWidth(ofView: amountWithoutDiscount, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
        }

        // Item amount
        itemView.totalAmount = buildItemAmount(with: itemComponent.props.installmentAmount, numberOfInstallments: itemComponent.props.numberOfInstallments, labelColor: ThemeManager.shared.boldLabelTintColor())

        if let totalAmount = itemView.totalAmount {
            itemView.addSubviewToBottom(totalAmount, withMargin: PXLayout.XS_MARGIN)
            PXLayout.matchWidth(ofView: totalAmount, withPercentage: CONTENT_TOTAL_WIDTH_PERCENT).isActive = true
            PXLayout.centerHorizontally(view: totalAmount).isActive = true
        }

        // Discount
        itemView.discountDescription = buildDiscountDescription(with: itemComponent.props.discountDescription, discountLimit: itemComponent.props.discountLimit)

        if let discountDescription = itemView.discountDescription {
            itemView.addSubviewToBottom(discountDescription, withMargin: PXLayout.XS_MARGIN)
            PXLayout.centerHorizontally(view: discountDescription).isActive = true
            PXLayout.matchWidth(ofView: discountDescription, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
        }

        itemView.pinLastSubviewToBottom(withMargin: PXLayout.ZERO_MARGIN)?.isActive = true

        // Arrow image.
        if itemComponent.props.shouldShowArrow {
            itemView.arrow = UIImageView(image: arrow)

            if let arrow = itemView.arrow {
                arrow.contentMode = .scaleAspectFit
                itemView.addSubview(arrow)
                PXLayout.setHeight(owner: arrow, height: PXLayout.XS_MARGIN).isActive = true
                PXLayout.setWidth(owner: arrow, width: PXLayout.XXS_MARGIN).isActive = true
                PXLayout.centerVertically(view: arrow, to: itemView.totalAmount).isActive = true
                PXLayout.pinRight(view: arrow, withMargin: PXLayout.XL_MARGIN).isActive = true
            }
        }
        return itemView
    }
}

extension PXOneTapItemRenderer {

    private func buildTitle(with text: String?, labelColor: UIColor) -> UILabel? {
        guard let text = text else {
            return nil
        }

        let font = Utils.getSemiBoldFont(size: PXOneTapItemRenderer.TITLE_FONT_SIZE)
        return buildLabel(text: text, color: labelColor, font: font)
    }

    private func buildItemAmount(with amount: Double?, numberOfInstallments: Int?, labelColor: UIColor) -> UILabel? {
        guard let amount = amount else {
            return nil
        }

        let font = Utils.getLightFont(size: PXOneTapItemRenderer.AMOUNT_FONT_SIZE)

        let installmentAmount = buildAttributedTotalAmount(amount: amount, color: labelColor, fontSize: font.pointSize)
        let totalAmount: NSMutableAttributedString = NSMutableAttributedString(attributedString: "".toAttributedString())

        // If there is more than one installment
        if let numberOfInstallments = numberOfInstallments, numberOfInstallments > 1 {
            totalAmount.append("\(numberOfInstallments.stringValue)x ".toAttributedString(attributes: [NSAttributedStringKey.font: font]))
        }
        totalAmount.append(installmentAmount)
        return buildLabel(attributedText: totalAmount, color: labelColor, font: font)
    }

    private func buildAmountWithoutDiscount(with amount: Double?, labelColor: UIColor) -> UILabel? {
        guard let amount = amount else {
            return nil
        }

        let font = Utils.getFont(size: PXOneTapItemRenderer.AMOUNT_WITHOUT_DISCOUNT_FONT_SIZE)
        let totalWithoutDiscount = NSMutableAttributedString(attributedString: buildAttributedTotalAmountWithoutDiscount(amount: amount, color: labelColor, font: font))
        return buildLabel(attributedText: totalWithoutDiscount, color: labelColor, font: font)
    }

    private func buildDiscountDescription(with description: String?, discountLimit: String?) -> UILabel? {
        guard let description = description else {
            return nil
        }

        let font = Utils.getFont(size: PXOneTapItemRenderer.DISCOUNT_DESCRIPTION_FONT_SIZE)
        let discountDescription = NSMutableAttributedString(string: description, attributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: ThemeManager.shared.noTaxAndDiscountLabelTintColor()])
        if let discountLimit = discountLimit {
            let discountLimitAtributtedString = NSMutableAttributedString(string: " \(discountLimit)", attributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: ThemeManager.shared.greyColor()])
            discountDescription.append(discountLimitAtributtedString)
        }
        return buildLabel(attributedText: discountDescription, color: ThemeManager.shared.greyColor(), font: font)
    }

    private func buildAttributedTotalAmount(amount: Double, color: UIColor, fontSize: CGFloat) -> NSAttributedString {
        let currency = MercadoPagoContext.getCurrency()
        return Utils.getAttributedAmount(amount, currency: currency, color: color, fontSize: fontSize, centsFontSize: 20, baselineOffset: 16, lightFont: true)
    }

    private func buildAttributedTotalAmountWithoutDiscount(amount: Double, color: UIColor, font: UIFont) -> NSAttributedString {
        let currency = MercadoPagoContext.getCurrency()
        let amount = Utils.getAmountFormatted(amount: amount, thousandSeparator: currency.thousandsSeparator, decimalSeparator: currency.decimalSeparator, addingCurrencySymbol: currency.symbol).toAttributedString()
        let amountString = NSMutableAttributedString(attributedString: amount)
        amountString.addAttributes([NSAttributedStringKey.font: font], range: NSRange(location: 0, length: amount.length))
        amountString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSRange(location: 0, length: amount.length))
        return amountString
    }

    private func buildLabel(text: String, color: UIColor, font: UIFont) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.text = text
        label.textColor = color
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 2
        label.font = font
        let screenWidth = PXLayout.getScreenWidth(applyingMarginFactor: CONTENT_WIDTH_PERCENT)
        let height = UILabel.requiredHeight(forText: text, withFont: font, inNumberOfLines: 2, inWidth: screenWidth)
        PXLayout.setHeight(owner: label, height: height).isActive = true
        return label
    }

    private func buildLabel(attributedText: NSAttributedString, color: UIColor, font: UIFont) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = color
        label.adjustsFontSizeToFitWidth = true
        label.attributedText = attributedText
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1

        PXLayout.setHeight(owner: label, height: font.pointSize).isActive = true
        return label
    }

    private func buildItemImageUrl(collectorImage: UIImage? = nil) -> UIImage? {
        if let image = collectorImage {
            return image
        } else {
            return MercadoPago.getImage("MPSDK_review_iconoCarrito")
        }
    }
}
