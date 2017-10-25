//
//  PXCard.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXCard: NSObject, Codable {
    open var cardHolder: PXCardHolder!
    open var customerId: String!
    open var dateCreated: Date?
    open var lastUpdated: Date?
    open var expirationMonth: Int!
    open var expirationYear: Int!
    open var firstSixDigits: String!
    open var id: String!
    open var issuer: PXIssuer!
    open var lastFourDigits: String!
    open var paymentMethod: PXPaymentMethod!
    open var securityCode: PXSecurityCode!

    init(cardHolder: PXCardHolder, customerId: String, dateCreated: Date?, lastUpdated: Date?, expirationMonth: Int, expirationYear: Int, firstSixDigits: String, id: String, issuer: PXIssuer, lastFourDigits: String, paymentMethod: PXPaymentMethod, securityCode: PXSecurityCode) {

        self.cardHolder = cardHolder
        self.customerId = customerId
        self.dateCreated = dateCreated
        self.lastUpdated = lastUpdated
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.firstSixDigits = firstSixDigits
        self.id = id
        self.issuer = issuer
        self.lastFourDigits = lastFourDigits
        self.paymentMethod = paymentMethod
        self.securityCode = securityCode
    }

    public enum PXCardKeys: String, CodingKey {
        case cardHolder = "cardholder"
        case customerId = "customer_id"
        case dateCreated = "date_created"
        case lastUpdated = "last_Updated"
        case expirationMonth = "expiration_month"
        case expirationYear = "expiration_year"
        case firstSixDigits = "first_six_digits"
        case id
        case issuer
        case lastFourDigits = "last_four_digits"
        case paymentMethod = "payment_method"
        case securityCode = "security_code"
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXCardKeys.self)
        let cardHolder: PXCardHolder = try container.decode(PXCardHolder.self, forKey: .cardHolder)
        let customerId: String = try container.decode(String.self, forKey: .customerId)
//        let dateCreated: Date? = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
//        let lastUpdated: Date? = try container.decodeIfPresent(Date.self, forKey: .lastUpdated)
        let expirationMonth: Int = try container.decode(Int.self, forKey: .expirationMonth)
        let expirationYear: Int = try container.decode(Int.self, forKey: .expirationYear)
        let firstSixDigits: String = try container.decode(String.self, forKey: .firstSixDigits)
        let id: String = try container.decode(String.self, forKey: .id)
        let issuer: PXIssuer = try container.decode(PXIssuer.self, forKey: .issuer)
        let lastFourDigits: String = try container.decode(String.self, forKey: .lastFourDigits)
        let paymentMethod: PXPaymentMethod = try container.decode(PXPaymentMethod.self, forKey: .paymentMethod)
        let securityCode: PXSecurityCode = try container.decode(PXSecurityCode.self, forKey: .securityCode)

        // TODO: Agrgegar

        self.init(cardHolder: cardHolder, customerId: customerId, dateCreated: nil, lastUpdated: nil, expirationMonth: expirationMonth, expirationYear: expirationYear, firstSixDigits: firstSixDigits, id: id, issuer: issuer, lastFourDigits: lastFourDigits, paymentMethod: paymentMethod, securityCode: securityCode)
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

    open class func fromJSON(data: Data) throws -> PXCard {
        return try JSONDecoder().decode(PXCard.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXCard] {
        return try JSONDecoder().decode([PXCard].self, from: data)
    }

}
