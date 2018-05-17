//
//  DiscountBodyCell.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/5/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class DiscountBodyCell: UIView {

    let DISCOUNT_COLOR = ThemeManager.shared.noTaxAndDiscountLabelTintColor()
    let LABEL_COLOR = ThemeManager.shared.boldLabelTintColor()
    let ACCENT_LINK = ThemeManager.shared.secondaryColor()
    let PRIMARY_BUTTON_TEXT_COLOR = ThemeManager.shared.whiteColor()
    let SEPARATOR_BORDER_COLOR: UIColor = UIColor.UIColorFromRGB(0x999999)

    let margin: CGFloat = 5.0
    var topMargin: CGFloat!
    var coupon: DiscountCoupon?
    var amount: Double!
    var hideArrow: Bool = false

    static let HEIGHT: CGFloat = 86.0

    init(frame: CGRect, coupon: DiscountCoupon?, amount: Double, addBorder: Bool = true, topMargin: CGFloat = 20.0, hideArrow: Bool = false) {
        super.init(frame: frame)
        self.coupon = coupon
        self.amount = amount
        self.topMargin = topMargin
        self.hideArrow = hideArrow
        if self.coupon == nil {
            loadNoCouponView()
        } else {
            loadCouponView()
        }
        if addBorder {
            self.addSeparatorLineToBottom(height: 1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadNoCouponView() {
        let screenWidth = frame.size.width

        let amountFontSize: CGFloat = 16
        let centsFontSize: CGFloat = 12
        let currency = MercadoPagoContext.getCurrency()
        let currencySymbol = currency.getCurrencySymbolOrDefault()
        let thousandSeparator = currency.getThousandsSeparatorOrDefault()
        let decimalSeparator = currency.getDecimalSeparatorOrDefault()
        let attributedTitle = NSMutableAttributedString(string: "Total: ".localized, attributes: [NSAttributedStringKey.font: Utils.getFont(size: amountFontSize)])

        let attributedAmount = Utils.getAttributedAmount(amount, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator, currencySymbol: currencySymbol, color: UIColor.px_white(), fontSize: amountFontSize, centsFontSize: centsFontSize, baselineOffset: 3, smallSymbol: false)
        attributedTitle.append(attributedAmount)

        let props = PXContainedLabelProps(labelText: attributedTitle)
        let component = PXContainedLabelComponent(props: props)
        let view = component.render()
        self.addSubview(view)
        PXLayout.pinTop(view: view, withMargin: 20).isActive = true
        PXLayout.setHeight(owner: view, height: 20).isActive = true
        PXLayout.matchWidth(ofView: view).isActive = true
        PXLayout.centerHorizontally(view: view).isActive = true

        let couponFlag = UIImageView()
        couponFlag.image = MercadoPago.getImage("iconDiscount")
        couponFlag.image = couponFlag.image?.withRenderingMode(.alwaysTemplate)
        couponFlag.tintColor = ACCENT_LINK
        let rightArrow = UIImageView()
        if !self.hideArrow {
            rightArrow.image = MercadoPago.getImage("rightArrow")
        }
        rightArrow.image = rightArrow.image?.withRenderingMode(.alwaysTemplate)
        rightArrow.tintColor = ACCENT_LINK
        let detailLabel = MPLabel()
        detailLabel.textAlignment = .center
        detailLabel.text = "Tengo un descuento".localized
        detailLabel.textColor = ACCENT_LINK
        detailLabel.font = Utils.getFont(size: 16)
        let widthlabelDiscount = detailLabel.attributedText?.widthWithConstrainedHeight(height: 18)
        let totalViewWidth = widthlabelDiscount! + 20 + 8 + 2 * margin
        var xPos = (screenWidth - totalViewWidth) / 2
        let frameFlag = CGRect(x: xPos, y: (margin * 2 + 40), width: 20, height: 20)
        couponFlag.frame = frameFlag
        xPos += 20 + margin
        let frameLabel = CGRect(x: xPos, y: (margin * 2 + 40), width: widthlabelDiscount!, height: 18)
        detailLabel.frame = frameLabel
        xPos += widthlabelDiscount! + margin
        let frameArrow = CGRect(x: xPos, y: 4 + (margin * 2 + 40), width: 8, height: 12)
        rightArrow.frame = frameArrow
        self.addSubview(couponFlag)
        self.addSubview(detailLabel)
        self.addSubview(rightArrow)
    }

    func loadCouponView() {
        let currency = MercadoPagoContext.getCurrency()
        let screenWidth = frame.size.width
        guard let coupon = self.coupon else {
            return
        }
        let tituloLabel = MPLabel(frame: CGRect(x: margin, y: topMargin, width: (frame.size.width - 2 * margin), height: 20) )
        tituloLabel.textAlignment = .center
        let result = NSMutableAttributedString()
        let normalAttributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: Utils.getFont(size: 16), NSAttributedStringKey.foregroundColor: LABEL_COLOR]
        let total = NSMutableAttributedString(string: "Total: ".localized, attributes: normalAttributes)
        let space = NSMutableAttributedString(string: " ".localized, attributes: normalAttributes)
        let oldAmount = Utils.getAttributedAmount( coupon.amountWithoutDiscount, currency: currency, color: LABEL_COLOR, fontSize: 16, baselineOffset: 4)

        oldAmount.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSRange(location: 0, length: oldAmount.length))
        let newAmount = Utils.getAttributedAmount( coupon.newAmount(), currency: currency, color: DISCOUNT_COLOR, fontSize: 16, baselineOffset: 4)
        result.append(total)
        result.append(oldAmount)
        result.append(space)
        result.append(newAmount)
        tituloLabel.attributedText = result
        let picFlag = UIImageView()
        picFlag.image = MercadoPago.getImage("couponArrowFlag")
        picFlag.image = picFlag.image?.withRenderingMode(.alwaysTemplate)
        picFlag.tintColor = DISCOUNT_COLOR
        let rightArrow = UIImageView()

        if !self.hideArrow {
            rightArrow.image = MercadoPago.getImage("rightArrow")
        }

        let detailLabel = MPLabel()
        detailLabel.textAlignment = .center
        if let concept = coupon.concept {
           detailLabel.text = concept
        } else {
           detailLabel.text = "Descuento".localized
        }
        detailLabel.textColor = DISCOUNT_COLOR
        detailLabel.font = Utils.getFont(size: 16)
        let discountAmountLabel = MPLabel()
        discountAmountLabel.textAlignment = .center
        discountAmountLabel.text = coupon.getDiscountDescription()
        discountAmountLabel.backgroundColor = DISCOUNT_COLOR
        discountAmountLabel.textColor = PRIMARY_BUTTON_TEXT_COLOR
        discountAmountLabel.font = Utils.getFont(size: 12)

        let widthlabelDiscount = detailLabel.attributedText?.widthWithConstrainedHeight(height: 18)
        let widthlabelAmount = (discountAmountLabel.attributedText?.widthWithConstrainedHeight(height: 12))! + 10
        let totalViewWidth = widthlabelDiscount! + widthlabelAmount + 10 + 8 + 2 * margin
        var xPos = (screenWidth - totalViewWidth) / 2
        let frameLabel = CGRect(x: xPos, y: (margin * 2 + topMargin + 20), width: widthlabelDiscount!, height: 18)
        detailLabel.frame = frameLabel
        xPos += widthlabelDiscount! + margin
        let framePic = CGRect(x: xPos, y: (margin * 2 + topMargin + 20), width: 10, height: 19)
        picFlag.frame = framePic
        xPos += 10
        let frameAmountLabel = CGRect(x: xPos, y: (margin * 2 + topMargin + 20), width: widthlabelAmount, height: 19)
        discountAmountLabel.frame = frameAmountLabel
        xPos += widthlabelAmount + margin
        let frameArrow = CGRect(x: xPos, y: 4 + (margin * 2 + topMargin + 20), width: 8, height: 12)
        rightArrow.frame = frameArrow

        let path = UIBezierPath(roundedRect: discountAmountLabel.bounds,
                                byRoundingCorners: [.topRight, .bottomRight],
                                cornerRadii: CGSize(width: 2, height: 2))

        let maskLayer = CAShapeLayer()

        maskLayer.path = path.cgPath

        discountAmountLabel.layer.mask = maskLayer

        self.addSubview(tituloLabel)
        self.addSubview(detailLabel)
        self.addSubview(picFlag)
        self.addSubview(discountAmountLabel)
        self.addSubview(rightArrow)
    }
}
