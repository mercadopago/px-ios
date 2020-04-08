//
//  PXOneTapDto.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 23/10/18.
//

import Foundation

public struct PXOneTapDisplayInfo: Codable {
    let bottomDescription: PXText?

    enum CodingKeys: String, CodingKey {
        case bottomDescription = "bottom_description"
    }
}

/// :nodoc:
open class PXOneTapDto: NSObject, Codable {
    open var paymentMethodId: String?
    open var paymentTypeId: String?
    open var oneTapCard: PXOneTapCardDto?
    open var oneTapCreditsInfo: PXOneTapCreditsDto?
    open var accountMoney: PXAccountMoneyDto?
    open var newCard: PXOneTapNewCardDto?
    open var benefits: PXBenefits?
    open var status: PXStatus
    open var offlineMethods: PXOfflineMethods?
    open var behaviours: [String: PXBehaviour]?
    open var displayInfo: PXOneTapDisplayInfo?

    public init(paymentMethodId: String?, paymentTypeId: String?, oneTapCard: PXOneTapCardDto?, oneTapCreditsInfo: PXOneTapCreditsDto?, accountMoney: PXAccountMoneyDto?, newCard: PXOneTapNewCardDto?, status: PXStatus, benefits: PXBenefits? = nil, offlineMethods: PXOfflineMethods?, behaviours: [String: PXBehaviour]?, displayInfo: PXOneTapDisplayInfo?) {
        self.paymentMethodId = paymentMethodId
        self.paymentTypeId = paymentTypeId
        self.oneTapCard = oneTapCard
        self.oneTapCreditsInfo = oneTapCreditsInfo
        self.accountMoney = accountMoney
        self.newCard = newCard
        self.status = status
        self.benefits = benefits
        self.offlineMethods = offlineMethods
        self.behaviours = behaviours
        self.displayInfo = displayInfo
    }

    public enum CodingKeys: String, CodingKey {
        case paymentMethodId = "payment_method_id"
        case paymentTypeId = "payment_type_id"
        case oneTapCard = "card"
        case oneTapCreditsInfo = "consumer_credits"
        case accountMoney = "account_money"
        case newCard = "new_card"
        case status
        case benefits = "benefits"
        case offlineMethods = "offline_methods"
        case behaviours
        case displayInfo = "display_info"
    }
}
