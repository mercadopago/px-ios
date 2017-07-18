//
//  Token.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

open class Token: NSObject, CardInformationForm {
	open var _id: String!
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

	public init (_id: String, publicKey: String?, cardId: String!, luhnValidation: String!, status: String!,
        usedDate: String!, cardNumberLength: Int, creationDate: Date!, lastFourDigits: String!, firstSixDigit: String!,
		securityCodeLength: Int, expirationMonth: Int, expirationYear: Int, lastModifiedDate: Date!,
		dueDate: Date?, cardHolder: Cardholder?, esc: String? = nil) {
			self._id = _id
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

    public convenience init (_id: String, publicKey: String?, cardId: String!, luhnValidation: String!, status: String!,
                 usedDate: String!, cardNumberLength: Int, creationDate: Date!, lastFourDigits: String!, firstSixDigit: String!,
                 securityCodeLength: Int, expirationMonth: Int, expirationYear: Int, lastModifiedDate: Date!,
                 dueDate: Date?, cardHolder: Cardholder?) {
        self.init(_id: _id, publicKey: publicKey, cardId: cardId, luhnValidation: luhnValidation, status: status,
              usedDate: usedDate, cardNumberLength: cardNumberLength, creationDate: creationDate, lastFourDigits : lastFourDigits, firstSixDigit : firstSixDigit,
              securityCodeLength: securityCodeLength, expirationMonth: expirationMonth, expirationYear: expirationYear, lastModifiedDate: lastModifiedDate,
              dueDate: dueDate, cardHolder: cardHolder, esc: nil)
    }

    open func getBin() -> String? {
        var bin: String? = nil
        if firstSixDigit != nil && firstSixDigit.characters.count > 0 {
            let range = firstSixDigit!.startIndex ..< firstSixDigit!.characters.index(firstSixDigit!.characters.startIndex, offsetBy: 6)
            bin = firstSixDigit!.characters.count >= 6 ? firstSixDigit!.substring(with: range) : nil
        }

        return bin
    }

	open class func fromJSON(_ json: NSDictionary) -> Token {
        let literalJson = json
        let _id = JSONHandler.attemptParseToString(literalJson["id"])
        let key = JSONHandler.attemptParseToString(literalJson[MercadoPagoContext.keyType()])
		let cardId =  JSONHandler.attemptParseToString(literalJson["card_id"])
		let status = JSONHandler.attemptParseToString(literalJson["status"])
		let luhn = JSONHandler.attemptParseToString(literalJson["luhn_validation"], defaultReturn: "")
		let usedDate = JSONHandler.attemptParseToString(literalJson["date_used"], defaultReturn: "")
		let cardNumberLength = JSONHandler.attemptParseToInt(literalJson["date_used"], defaultReturn: 0)

		let lastFourDigits = JSONHandler.attemptParseToString(literalJson["last_four_digits"], defaultReturn: "")
        let firstSixDigits = JSONHandler.attemptParseToString(literalJson["first_six_digits"], defaultReturn: "")
		let securityCodeLength = JSONHandler.attemptParseToInt(literalJson["security_code_length"], defaultReturn: 0)
        let expMonth = JSONHandler.attemptParseToInt(literalJson["expiration_month"], defaultReturn: 0)
		let expYear = JSONHandler.attemptParseToInt(literalJson["expiration_year"], defaultReturn: 0)

        let esc = JSONHandler.attemptParseToString(literalJson["esc"])

        var cardHolder: Cardholder? = nil
        if let dic = json["cardholder"] as? NSDictionary {
            cardHolder = Cardholder.fromJSON(dic)
        }

		let lastModifiedDate = json.isKeyValid("date_last_updated") ? Utils.getDateFromString(json["date_last_updated"] as? String) : Date()
		let dueDate = json.isKeyValid("date_due") ? Utils.getDateFromString(json["date_due"] as? String) : Date()
        let creationDate = json.isKeyValid("date_created") ? Utils.getDateFromString(json["date_created"] as? String) : Date()

		return Token(_id: _id!, publicKey: key, cardId: cardId, luhnValidation: luhn, status: status,
			usedDate: usedDate, cardNumberLength: cardNumberLength!, creationDate: creationDate, lastFourDigits : lastFourDigits, firstSixDigit : firstSixDigits,
			securityCodeLength: securityCodeLength!, expirationMonth: expMonth!, expirationYear: expYear!, lastModifiedDate: lastModifiedDate,
			dueDate: dueDate, cardHolder: cardHolder, esc: esc)
	}

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    open func toJSON() -> [String:Any] {
        let _id : Any = self._id == nil ? JSONHandler.null : self._id!
        let cardId : Any = self.cardId == nil ? JSONHandler.null : self.cardId!
        let luhn : Any =  self.luhnValidation == nil ? JSONHandler.null : self.luhnValidation!
        let lastFour : Any = self.lastFourDigits == nil ? JSONHandler.null : self.lastFourDigits
        let firstSix : Any =  self.firstSixDigit == nil ? JSONHandler.null : self.firstSixDigit
        let cardHolderToJsonString: Any = self.cardHolder?.toJSON() ?? JSONHandler.null
        let esc: Any = String.isNullOrEmpty(self.esc) ? JSONHandler.null : self.esc

        let obj: [String:Any] = [
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
           masknumber = masknumber + "X"
        }

           masknumber = masknumber + lastFourDigits
        return masknumber

    }
    open func getExpirationDateFormated() -> String {

        if self.expirationYear > 0 && self.expirationMonth > 0 {
            return String(self.expirationMonth) + "/" + String(self.expirationYear).substring(from: String(self.expirationYear).index(before: String(self.expirationYear).characters.index(before: String(self.expirationYear).endIndex)))
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

public func ==(obj1: Token, obj2: Token) -> Bool {

    let areEqual =
    obj1._id == obj2._id &&
    obj1.publicKey == obj2.publicKey &&
    obj1.cardId == obj2.cardId &&
    obj1.luhnValidation == obj2.luhnValidation &&
    obj1.status == obj2.status &&
    obj1.usedDate == obj2.usedDate &&
   // obj1.cardNumberLength == obj2.cardNumberLength &&
  //  obj1.creationDate == obj2.creationDate &&
    obj1.firstSixDigit == obj2.firstSixDigit &&
    obj1.lastFourDigits == obj2.lastFourDigits &&
    obj1.securityCodeLength == obj2.securityCodeLength &&
    obj1.expirationMonth == obj2.expirationMonth &&
    obj1.expirationYear == obj2.expirationYear &&
    obj1.lastModifiedDate == obj2.lastModifiedDate// &&
  //  obj1.dueDate == obj2.dueDate

    return areEqual
}
