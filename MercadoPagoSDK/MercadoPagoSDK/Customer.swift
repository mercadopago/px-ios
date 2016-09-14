//
//  Customer.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

public class Customer : NSObject {
    public var address : Address?
    public var cards : [Card]?
    public var defaultCard : NSNumber?
    public var _description : String?
    public var dateCreated : NSDate?
    public var dateLastUpdated : NSDate?
    public var email : String?
    public var firstName : String?
    public var _id : String?
    public var identification : Identification?
    public var lastName : String?
    public var liveMode : Bool?
    public var metadata : NSDictionary?
    public var phone : Phone?
    public var registrationDate : NSDate?
    
    public class func fromJSON(json : NSDictionary) -> Customer {
        let customer : Customer = Customer()
        customer._id = json["id"] as! String!
        customer.liveMode = json["live_mode"] as? Bool!
        customer.email = json["email"] as? String!
        customer.firstName = json["first_name"] as? String!
        customer.lastName = json["last_name"] as? String!
        customer._description = json["description"] as? String!
		if json["default_card"] != nil {
			customer.defaultCard = json["default_card"]?.longValue
		}
        if let identificationDic = json["identification"] as? NSDictionary {
            customer.identification = Identification.fromJSON(identificationDic)
        }
        if let phoneDic = json["phone"] as? NSDictionary {
            customer.phone = Phone.fromJSON(phoneDic)
        }
        if let addressDic = json["address"] as? NSDictionary {
            customer.address = Address.fromJSON(addressDic)
        }
        customer.metadata = json["metadata"]! as? NSDictionary
        customer.dateCreated = Utils.getDateFromString(json["date_created"] as? String)
        customer.dateLastUpdated = Utils.getDateFromString(json["date_last_updated"] as? String)
        customer.registrationDate = Utils.getDateFromString(json["date_registered"] as? String)
        var cards : [Card] = [Card]()
        if let cardsArray = json["cards"] as? NSArray {
            for i in 0..<cardsArray.count {
                if let cardDic = cardsArray[i] as? NSDictionary {
                    cards.append(Card.fromJSON(cardDic))
                }
            }
        }
        customer.cards = cards
        return customer
    }
    
    public func toJSONString() -> String {
        let obj:[String:AnyObject] = [
            "defaultCard": self.defaultCard != nil ? JSON.null : self.defaultCard!,
            "_description" : self._description == nil ? JSON.null : self._description!,
            "dateCreated" : self.dateCreated == nil ? JSON.null : self.dateCreated!,
            "email" : self.email == nil ? JSON.null : self.email!,
            "firstName" : self.firstName == nil ? JSON.null : self.firstName!,
            "lastName" : self.lastName == nil ? JSON.null : self.lastName!,
            "_id" : self._id == nil ? JSON.null : self._id!
            ]
        return JSON(obj).toString()
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



