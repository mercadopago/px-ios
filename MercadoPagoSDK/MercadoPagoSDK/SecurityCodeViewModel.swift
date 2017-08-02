//
//  SecurityCodeViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 7/17/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class SecurityCodeViewModel: NSObject {
    var paymentMethod: PaymentMethod!
    var cardInfo: CardInformationForm!

    var callback: ((_ cardInformation: CardInformationForm, _ securityCode: String) -> Void)?

    public init(paymentMethod: PaymentMethod, cardInfo: CardInformationForm) {
        self.paymentMethod = paymentMethod
        self.cardInfo = cardInfo
    }

    func secCodeInBack() -> Bool {
        return paymentMethod.secCodeInBack()
    }
    func secCodeLenght() -> Int {
        return paymentMethod.secCodeLenght()
    }

    func executeCallback(secCode: String!) {
        callback!(cardInfo, secCode)
    }

    func getPaymentMethodColor() -> UIColor {
        return self.paymentMethod.getColor(bin: self.cardInfo.getCardBin())
    }

    func getPaymentMethodFontColor() -> UIColor {
        return self.paymentMethod.getFontColor(bin: self.cardInfo.getCardBin())
    }

    func getCardHeight() -> CGFloat {
        return getCardWidth() / 12 * 7
    }

    func getCardWidth() -> CGFloat {
        return (UIScreen.main.bounds.width - 100)
    }
    func getCardX() -> CGFloat {
        return ((UIScreen.main.bounds.width - getCardWidth())/2)
    }

    func getCardY() -> CGFloat {
        let cardSeparation: CGFloat = 510
        let y = (UIScreen.main.bounds.height - getCardHeight() - cardSeparation) / 2
        return y>10 ? y : 10
    }

    func getCardBounds() -> CGRect {
        return CGRect(x: getCardX(), y: getCardY(), width: getCardWidth(), height: getCardHeight())
    }
}
