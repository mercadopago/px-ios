//
//  PXOneTapViewModel+PaymentMethodComponent.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 15/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

// One Tap - Payment method component.
extension PXOneTapViewModel {

    func getPaymentMethodComponent() -> PXPaymentMethodComponent? {
        guard let pm = self.amountHelper.paymentData.getPaymentMethod() else {
            return nil
        }

        let paymentMethodName = pm.name ?? ""
        let image = PXImageService.getIconImageFor(paymentMethod: pm)
        var title = NSAttributedString(string: "")
        var subtitle: NSAttributedString? = pm.paymentMethodDescription?.toAttributedString()
        var cftText: NSAttributedString? = nil
        var subtitleRight: NSMutableAttributedString? = nil
        let backgroundColor = ThemeManager.shared.whiteColor()
        let lightLabelColor = ThemeManager.shared.labelTintColor()
        let boldLabelColor = ThemeManager.shared.boldLabelTintColor()
        let currency: Currency = MercadoPagoContext.getCurrency()

        if pm.isCard {
            if let lastFourDigits = (self.amountHelper.paymentData.token?.lastFourDigits) {
                let text = "\(paymentMethodName) ···· \(lastFourDigits)"
                title = text.toAttributedString()
            } else if let card = paymentOptionSelected as? CustomerPaymentMethod {
                if let lastFourDigits = card.getCardLastForDigits() {
                    let text: String = "\(paymentMethodName) ···· \(lastFourDigits)"
                    title = text.toAttributedString()
                }
            }
        } else {
            title = paymentMethodName.toAttributedString()
        }

        if self.amountHelper.discount != nil {
            // With discount
            if let pCost = self.amountHelper.paymentData.payerCost, pCost.installments > 1 {
                let amount: String = Utils.getAmountFormatted(amount: self.amountHelper.preferenceAmountWithCharges, thousandSeparator: currency.getThousandsSeparatorOrDefault(), decimalSeparator: currency.getDecimalSeparatorOrDefault(), addingCurrencySymbol: currency.getCurrencySymbolOrDefault(), addingParenthesis: false)
                subtitleRight = amount.toAttributedString()

                let amountWithDiscount: String = Utils.getAmountFormatted(amount: getTotalAmount(), thousandSeparator: currency.getThousandsSeparatorOrDefault(), decimalSeparator: currency.getDecimalSeparatorOrDefault(), addingCurrencySymbol: currency.getCurrencySymbolOrDefault(), addingParenthesis: true)
                subtitle = amountWithDiscount.toAttributedString()
            }
        } else {
            // Without discount
            if let pCost = self.amountHelper.paymentData.payerCost, pCost.installments > 1 {
                let totalAmount: String = Utils.getAmountFormatted(amount: getTotalAmount(), thousandSeparator: currency.getThousandsSeparatorOrDefault(), decimalSeparator: currency.getDecimalSeparatorOrDefault(), addingCurrencySymbol: currency.getCurrencySymbolOrDefault(), addingParenthesis: true)
                subtitle = totalAmount.toAttributedString()
            }
        }

        if let attrSubtitleRight = subtitleRight {
            attrSubtitleRight.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSRange(location: 0, length: attrSubtitleRight.length))
        }

        // CFT.
        if let payerCost = self.amountHelper.paymentData.getPayerCost(), let cftValue = payerCost.getCFTValue(), payerCost.hasCFTValue() {
            cftText = "CFT: \(cftValue)".toAttributedString()
        }

        let props = PXPaymentMethodProps(paymentMethodIcon: image, title: title, subtitle: subtitle, descriptionTitle: subtitleRight, descriptionDetail: cftText, disclaimer: nil, action: nil, backgroundColor: backgroundColor, lightLabelColor: lightLabelColor, boldLabelColor: boldLabelColor)
        return PXPaymentMethodComponent(props: props)
    }
}
