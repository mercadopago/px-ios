//
//  PXCardSliderApplicationData.swift
//  MercadoPagoSDKV4
//
//  Created by Jonathan Scaramal on 09/03/2021.
//

import MLCardDrawer

final class PXCardSliderApplicationData {
    var paymentMethodId: String
    var paymentTypeId: String?
    var shouldShowArrow: Bool
    var cardData: CardData?
    var selectedPayerCost: PXPayerCost?
    var payerCost: [PXPayerCost] = [PXPayerCost]()
    var displayMessage: NSAttributedString?
    var amountConfiguration: PXAmountConfiguration?
    var status: PXStatus
    var bottomMessage: PXCardBottomMessage?
    var benefits: PXBenefits?
    var behaviours: [String: PXBehaviour]?
    var userDidSelectPayerCost: Bool = false
    var payerPaymentMethod: PXCustomOptionSearchItem?
    var cardUI: CardUI?
    
    internal init(paymentMethodId: String, paymentTypeId: String?, cardData: CardData? = nil, cardUI: CardUI? = nil, payerCost: [PXPayerCost] = [PXPayerCost](), selectedPayerCost: PXPayerCost? = nil, shouldShowArrow: Bool, amountConfiguration: PXAmountConfiguration? = nil, status: PXStatus, bottomMessage: PXCardBottomMessage? = nil, benefits: PXBenefits? = nil, payerPaymentMethod: PXCustomOptionSearchItem? = nil, behaviours: [String : PXBehaviour]? = nil, displayInfo: PXOneTapDisplayInfo? = nil, displayMessage: NSAttributedString? = nil) {
        self.paymentMethodId = paymentMethodId
        self.paymentTypeId = paymentTypeId
        self.shouldShowArrow = shouldShowArrow
        self.cardData = cardData
        self.selectedPayerCost = selectedPayerCost
        self.payerCost = payerCost
        self.displayMessage = displayMessage
        self.amountConfiguration = amountConfiguration
        self.status = status
        self.bottomMessage = bottomMessage
        self.benefits = benefits
        self.behaviours = behaviours
        self.payerPaymentMethod = payerPaymentMethod
        self.cardUI = cardUI
    }
}
