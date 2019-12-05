//
//  PXOneTapDto.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 23/10/18.
//

import Foundation

/// :nodoc:
open class PXOneTapDto: NSObject, Codable {
    open var paymentMethodId: String
    open var paymentTypeId: String?
    open var oneTapCard: PXOneTapCardDto?
    open var oneTapCreditsInfo: PXOneTapCreditsDto?
    open var accountMoney: PXAccountMoneyDto?
    open var newCard: PXOneTapNewCardDto?
    open var status: PXStatus

    public init(paymentMethodId: String?, paymentTypeId: String?, oneTapCard: PXOneTapCardDto?, oneTapCreditsInfo: PXOneTapCreditsDto?, accountMoney: PXAccountMoneyDto?, newCard: PXOneTapNewCardDto?, status: PXStatus) {
        self.paymentMethodId = paymentMethodId ?? ""
        self.paymentTypeId = paymentTypeId
        self.oneTapCard = oneTapCard
        self.oneTapCreditsInfo = oneTapCreditsInfo
        self.accountMoney = accountMoney
        self.newCard = newCard
        self.status = status
    }

    public enum PXOneTapDtoKeys: String, CodingKey {
        case paymentMethodId = "payment_method_id"
        case paymentTypeId = "payment_type_id"
        case oneTapCard = "card"
        case oneTapCreditsInfo = "consumer_credits"
        case accountMoney = "account_money"
        case newCard = "new_card"
        case status
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXOneTapDtoKeys.self)
        let oneTapCard: PXOneTapCardDto? = try container.decodeIfPresent(PXOneTapCardDto.self, forKey: .oneTapCard)
        let oneTapCreditsInfo: PXOneTapCreditsDto? = try container.decodeIfPresent(PXOneTapCreditsDto.self, forKey: .oneTapCreditsInfo)
        let paymentMethodId: String? = try container.decodeIfPresent(String.self, forKey: .paymentMethodId)
        let paymentTypeId: String? = try container.decodeIfPresent(String.self, forKey: .paymentTypeId)
        let aMoney: PXAccountMoneyDto? = try container.decodeIfPresent(PXAccountMoneyDto.self, forKey: .accountMoney)
        let newCard: PXOneTapNewCardDto? = try container.decodeIfPresent(PXOneTapNewCardDto.self, forKey: .newCard)
        let status: PXStatus = try container.decode(PXStatus.self, forKey: .status)
        self.init(paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId, oneTapCard: oneTapCard, oneTapCreditsInfo: oneTapCreditsInfo, accountMoney: aMoney, newCard: newCard, status: status)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXOneTapDtoKeys.self)
        try container.encodeIfPresent(self.oneTapCard, forKey: .oneTapCard)
        try container.encodeIfPresent(self.oneTapCreditsInfo, forKey: .oneTapCreditsInfo)
        try container.encodeIfPresent(self.paymentMethodId, forKey: .paymentMethodId)
        try container.encodeIfPresent(self.paymentTypeId, forKey: .paymentTypeId)
        try container.encodeIfPresent(self.accountMoney, forKey: .accountMoney)
        try container.encodeIfPresent(self.newCard, forKey: .newCard)
        try container.encode(self.status, forKey: .status)
    }

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open class func fromJSON(data: Data) throws -> PXOneTapDto {
        return try JSONDecoder().decode(PXOneTapDto.self, from: data)
    }
}
