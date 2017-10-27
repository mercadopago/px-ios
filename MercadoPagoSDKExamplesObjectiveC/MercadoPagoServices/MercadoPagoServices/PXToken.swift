//
//  PXToken.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXToken: NSObject, Codable {
    open var id: String!
    open var publicKey: String!
    open var cardId: String?
    open var luhnValidation: String!
    open var status: String!
    open var usedDate: Date?
    open var cardNumberLength: Int!
    open var dateCreated: Date?
    open var securityCodeLength: Int!
    open var expirationMonth: Int!
    open var expirationYear: Int!
    open var dateLastUpdated: Date?
    open var dueDate: Date?
    open var firstSixDigits: String!
    open var lastFourDigits: String!
    open var cardholder: PXCardHolder!
    open var esc: String!

    init(id: String, publicKey: String, cardId: String?, luhnValidation: String, status: String, usedDate: Date?, cardNumberLength: Int, dateCreated: Date?, securityCodeLength: Int, expirationMonth: Int, expirationYear: Int, dateLastUpdated: Date?, dueDate: Date?, firstSixDigits: String, lastFourDigits: String, cardholder: PXCardHolder, esc: String) {

        self.id = id
        self.publicKey = publicKey
        self.cardId = cardId
        self.luhnValidation = luhnValidation
        self.status = status
        self.usedDate = usedDate
        self.cardNumberLength = cardNumberLength
        self.dateCreated = dateCreated
        self.securityCodeLength = securityCodeLength
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.dateLastUpdated = dateLastUpdated
        self.dueDate = dueDate
        self.firstSixDigits = firstSixDigits
        self.lastFourDigits = lastFourDigits
        self.cardholder = cardholder
        self.esc = esc
    }

    public enum PXTokenKeys: String, CodingKey {
        case id
        case publicKey = "public_key"
        case cardId = "card_id"
        case luhnValidation = "luhn_validation"
        case status
        case usedDate = "used_date"
        case cardNumberLength = "card_number_length"
        case dateCreated = "date_created"
        case securityCodeLength = "security_code_length"
        case expirationMonth = "expiration_month"
        case expirationYear = "expiration_year"
        case dateLastUpdated = "date_last_updated"
        case dueDate = "date_due"
        case firstSixDigits = "first_six_digits"
        case lastFourDigits = "last_four_digits"
        case cardholder
        case esc
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXTokenKeys.self)
        let id: String = try container.decode(String.self, forKey: .id)
        let publicKey: String = try container.decode(String.self, forKey: .publicKey)
        let cardId: String? = try container.decodeIfPresent(String.self, forKey: .cardId)
        let luhnValidation: String = try container.decode(String.self, forKey: .luhnValidation)
        let status: String = try container.decode(String.self, forKey: .status)
        //let usedDate: String = try container.decode(String.self, forKey: .usedDate)
        let cardNumberLength: Int = try container.decode(Int.self, forKey: .cardNumberLength)
        //let dateCreated: String = try container.decode(dateCreated.self, forKey: .dateCreated)
        let securityCodeLength: Int = try container.decode(Int.self, forKey: .securityCodeLength)
        let expirationMonth: Int = try container.decode(Int.self, forKey: .expirationMonth)
        let expirationYear: Int = try container.decode(Int.self, forKey: .expirationYear)
        //let dateLastUpdated: String = try container.decode(String.self, forKey: .dateLastUpdated)
        //let dueDate: String = try container.decode(String.self, forKey: .dueDate)
        let firstSixDigits: String = try container.decode(String.self, forKey: .firstSixDigits)
        let lastFourDigits: String = try container.decode(String.self, forKey: .lastFourDigits)
        let cardholder: PXCardHolder = try container.decode(PXCardHolder.self, forKey: .cardholder)
        let esc: String = try container.decode(String.self, forKey: .esc)


        self.init(id: id, publicKey: publicKey, cardId: cardId, luhnValidation: luhnValidation, status: status, usedDate: nil, cardNumberLength: cardNumberLength, dateCreated: nil, securityCodeLength: securityCodeLength, expirationMonth: expirationMonth, expirationYear: expirationYear, dateLastUpdated: nil, dueDate: nil, firstSixDigits: firstSixDigits, lastFourDigits: lastFourDigits, cardholder: cardholder, esc: esc)
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

    open class func fromJSON(data: Data) throws -> PXToken {
        return try JSONDecoder().decode(PXToken.self, from: data)
    }
}
