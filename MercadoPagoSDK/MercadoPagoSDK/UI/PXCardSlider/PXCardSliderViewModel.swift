//
//  PXCardSliderViewModel.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 31/10/18.
//

import UIKit

final class PXCardSliderViewModel {
    let paymentMethodId: String
    let issuerId: String
    let cardUI: CardUI
    let shouldShowArrow: Bool
    var accountMoneyBalance: Double?
    var payerCost: [PXPayerCost] = [PXPayerCost]()
    var cardData: CardData?
    var selectedPayerCost: PXPayerCost?
    var cardId: String?

    init(_ paymentMethodId: String, _ issuerId: String, _ cardUI: CardUI, _ cardData: CardData?, _ payerCost: [PXPayerCost], _ selectedPayerCost: PXPayerCost?, _ cardId: String? = nil, _ shouldShowArrow: Bool) {
        self.paymentMethodId = paymentMethodId
        self.issuerId = issuerId
        self.cardUI = cardUI
        self.cardData = cardData
        self.payerCost = payerCost
        self.selectedPayerCost = selectedPayerCost
        self.cardId = cardId
        self.shouldShowArrow = shouldShowArrow
    }
}

extension PXCardSliderViewModel: PaymentMethodOption {
    func getId() -> String {
        return paymentMethodId
    }

    func getDescription() -> String {
        return ""
    }

    func getComment() -> String {
        return ""
    }

    func hasChildren() -> Bool {
        return false
    }

    func getChildren() -> [PaymentMethodOption]? {
        return nil
    }

    func isCard() -> Bool {
        return PXPaymentTypes.ACCOUNT_MONEY.rawValue != paymentMethodId
    }

    func isCustomerPaymentMethod() -> Bool {
        return PXPaymentTypes.ACCOUNT_MONEY.rawValue != paymentMethodId
    }
}

// MARK: Setters
extension PXCardSliderViewModel {
    func setAccountMoney(accountMoneyBalance: Double) {
        self.accountMoneyBalance = accountMoneyBalance
    }
}
