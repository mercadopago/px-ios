//
//  Customer.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class Customer: NSObject {
    open var address: Address?
    open var cards: [Card]?
    open var defaultCard: String?
    open var _description: String?
    open var dateCreated: Date?
    open var dateLastUpdated: Date?
    open var email: String?
    open var firstName: String?
    open var _id: String?
    open var identification: Identification?
    open var lastName: String?
    open var liveMode: Bool?
    open var metadata: NSDictionary?
    open var phone: Phone?
    open var registrationDate: Date?

    open class func fromJSON(_ json: NSDictionary) -> Customer {
        let customer: Customer = Customer()
        customer._id = json["id"] as! String!
        customer.liveMode = json["live_mode"] as? Bool
        customer.email = json["email"] as? String
        customer.firstName = json["first_name"] as? String
        customer.lastName = json["last_name"] as? String
        customer._description = json["description"] as? String

        if let identificationDic = json["identification"] as? NSDictionary {
            customer.identification = Identification.fromJSON(identificationDic)
        }
        if let phoneDic = json["phone"] as? NSDictionary {
            customer.phone = Phone.fromJSON(phoneDic)
        }
        if let addressDic = json["address"] as? NSDictionary {
            customer.address = Address.fromJSON(addressDic)
        }
        if let defaultCard = json["default_card"] as? String {
            customer.defaultCard = defaultCard
        }
        customer.metadata = json["metadata"] as? NSDictionary
        customer.dateCreated = Utils.getDateFromString(json["date_created"] as? String)
        customer.dateLastUpdated = Utils.getDateFromString(json["date_last_updated"] as? String)
        customer.registrationDate = Utils.getDateFromString(json["date_registered"] as? String)
        var cards: [Card] = [Card]()
        if let cardsArray = json["cards"] as? NSArray {
            for i in 0..<cardsArray.count {
                if let cardDic = cardsArray[i] as? NSDictionary {
                    cards.append(Card.fromJSON(cardDic))
                }
            }
        }
        customer.cards = cards.isEmpty ? nil : cards
        return customer
    }

    open func toJSONString() -> String {
        let defaultCard : Any =  self.defaultCard == nil ? JSONHandler.null : self.defaultCard!
        let description : Any =   self._description == nil ? JSONHandler.null : self._description!
        let email : Any =  self.email == nil ? JSONHandler.null : self.email!
        let firstName : Any =   self.firstName == nil ? JSONHandler.null : self.firstName!
        let lastName : Any =   self.lastName == nil ? JSONHandler.null : self.lastName!
        let id : Any =   self._id == nil ? JSONHandler.null : self._id!
        let identification: Any = self.identification == nil ? JSONHandler.null : self.identification!.toJSON()
        let address: Any = self.address == nil ? JSONHandler.null : self.address!.toJSON()
        let liveMode: Any = self.liveMode == nil ? JSONHandler.null : self.liveMode!

        var obj: [String:Any] = [
            "default_card": defaultCard,
            "description": description,
            "date_created": Utils.getStringFromDate(self.dateCreated) ?? JSONHandler.null,
            "email": email,
            "first_name": firstName,
            "last_name": lastName,
            "id": id,
            "identification": identification,
            "live_mode": liveMode,
            "address": address
        ]

        var cardsJson: [[String:Any]] = []
        if !Array.isNullOrEmpty(cards) {
            for card in cards! {
                cardsJson.append(card.toJSON())
            }
            obj["cards"] = cardsJson

        } else {
            obj["cards"] = JSONHandler.null
        }

        return JSONHandler.jsonCoding(obj)
    }
}

public func ==(obj1: Customer, obj2: Customer) -> Bool {
    let areEqual =
        obj1.address! == obj2.address! &&
            obj1.cards! == obj2.cards! &&
            obj1.defaultCard! == obj2.defaultCard! &&
            obj1._description == obj2._description &&
            obj1.dateCreated == obj2.dateCreated &&
            obj1.dateLastUpdated == obj2.dateLastUpdated &&
            obj1.email == obj2.email &&
            obj1.firstName == obj2.firstName &&
            obj1._id == obj2._id &&
            obj1.identification == obj2.identification &&
            obj1.lastName == obj2.lastName &&
            obj1.liveMode == obj2.liveMode &&
            obj1.metadata == obj2.metadata &&
            obj1.phone == obj2.phone &&
            obj1.registrationDate == obj2.registrationDate
    return areEqual
}
