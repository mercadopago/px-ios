//
//  Token.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

open class Token: NSObject, CardInformationForm {
	open var tokenId: String!
	open var publicKey: String?
	open var cardId: String!
	open var luhnValidation: String!
	open var status: String!
	open var usedDate: String!
	open var cardNumberLength: Int = 0
	open var creationDate: Date!
	open var lastFourDigits: String!
    open var firstSixDigit: String!
	open var securityCodeLength: Int = 0
	open var expirationMonth: Int = 0
	open var expirationYear: Int = 0
	open var lastModifiedDate: Date!
	open var dueDate: Date!
    open var esc: String?

    open var cardHolder: Cardholder?

	public init (tokenId: String, publicKey: String?, cardId: String!, luhnValidation: String!, status: String!, usedDate: String!, cardNumberLength: Int, creationDate: Date!, lastFourDigits: String!, firstSixDigit: String!, securityCodeLength: Int, expirationMonth: Int, expirationYear: Int, lastModifiedDate: Date!, dueDate: Date?, cardHolder: Cardholder?, esc: String? = nil) {
			self.tokenId = tokenId
			self.publicKey = publicKey
			self.cardId = cardId
			self.luhnValidation = luhnValidation
			self.status = status
			self.usedDate = usedDate
			self.cardNumberLength = cardNumberLength
			self.creationDate = creationDate
			self.lastFourDigits = lastFourDigits
            self.firstSixDigit = firstSixDigit
			self.securityCodeLength = securityCodeLength
			self.expirationMonth = expirationMonth
			self.expirationYear = expirationYear
			self.lastModifiedDate = lastModifiedDate
			self.dueDate = dueDate
            self.cardHolder = cardHolder
            self.esc = esc
	}

    public convenience init (tokenId: String, publicKey: String?, cardId: String!, luhnValidation: String!, status: String!, usedDate: String!, cardNumberLength: Int, creationDate: Date!, lastFourDigits: String!, firstSixDigit: String!, securityCodeLength: Int, expirationMonth: Int, expirationYear: Int, lastModifiedDate: Date!, dueDate: Date?, cardHolder: Cardholder?) {
        self.init(tokenId: tokenId, publicKey: publicKey, cardId: cardId, luhnValidation: luhnValidation, status: status,
              usedDate: usedDate, cardNumberLength: cardNumberLength, creationDate: creationDate, lastFourDigits: lastFourDigits, firstSixDigit: firstSixDigit,
              securityCodeLength: securityCodeLength, expirationMonth: expirationMonth, expirationYear: expirationYear, lastModifiedDate: lastModifiedDate,
              dueDate: dueDate, cardHolder: cardHolder, esc: nil)
    }

    open func getBin() -> String? {
        var bin: String? = nil
        if firstSixDigit != nil && firstSixDigit.count > 0 {
            let range = firstSixDigit!.startIndex ..< firstSixDigit!.index(firstSixDigit!.startIndex, offsetBy: 6)
            bin = firstSixDigit!.count >= 6 ? firstSixDigit!.substring(with: range) : nil
        }

        return bin
    }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    open func toJSON() -> [String: Any] {
        let _id: Any = self.tokenId == nil ? JSONHandler.null : self.tokenId!
        let cardId: Any = self.cardId == nil ? JSONHandler.null : self.cardId!
        let luhn: Any =  self.luhnValidation == nil ? JSONHandler.null : self.luhnValidation!
        let lastFour: Any = self.lastFourDigits == nil ? JSONHandler.null : self.lastFourDigits
        let firstSix: Any =  self.firstSixDigit == nil ? JSONHandler.null : self.firstSixDigit
        let cardHolderToJsonString: Any = self.cardHolder?.toJSON() ?? JSONHandler.null

        //TODO: Change all json parse logic. Remove fromJson, tJson. Refactor of Network layer.
        let esc: Any = String.isNullOrEmpty(self.esc) ? JSONHandler.null : self.esc ?? ""

        let obj: [String: Any] = [
            "id": _id,
            "card_id": cardId,
            "luhn_validation": luhn,
            "status": self.status,
            "used_date": self.usedDate,
            "card_number_length": self.cardNumberLength,
            "creation_date": Utils.getStringFromDate(self.creationDate),
            "last_four_digits": lastFour,
            "first_six_digits": firstSix,
            "security_code_length": self.securityCodeLength,
            "expiration_month": self.expirationMonth,
            "expiration_year": self.expirationYear,
            "last_modified_date": Utils.getStringFromDate(self.lastModifiedDate),
            "due_date": Utils.getStringFromDate(self.dueDate),
            "cardholder": cardHolderToJsonString,
            "esc": esc
        ]

        return obj
    }

    open func getCardExpirationDateFormated() -> String {
        return (String(expirationMonth) + String(expirationYear))
    }

    open func getMaskNumber() -> String {

        var masknumber: String = ""

        for _ in 0...cardNumberLength-4 {
           masknumber += "X"
        }

           masknumber += lastFourDigits
        return masknumber

    }

    open func getExpirationDateFormated() -> String {
        if self.expirationYear > 0 && self.expirationMonth > 0 {
            return String(self.expirationMonth) + "/" + String(self.expirationYear).substring(from: String(self.expirationYear).index(before: String(self.expirationYear).index(before: String(self.expirationYear).endIndex)))
        }
        return ""
    }

    public func getCardBin() -> String? {
        return firstSixDigit
    }
    public func getCardLastForDigits() -> String? {
        return lastFourDigits
    }

    public func isIssuerRequired() -> Bool {
        return true
    }

    public func canBeClone() -> Bool {
        return true
    }

    public func hasESC() -> Bool {
        return !String.isNullOrEmpty(esc)
    }

    public func hasCardId() -> Bool {
        return !String.isNullOrEmpty(cardId)
    }
}

extension NSDictionary {
	public func isKeyValid(_ dictKey: String) -> Bool {
		let dictValue: Any? = self[dictKey]
		return (dictValue == nil || dictValue is NSNull) ? false : true
	}
}
