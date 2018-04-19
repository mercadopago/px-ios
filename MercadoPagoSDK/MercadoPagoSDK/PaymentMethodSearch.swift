//
//  PaymentMethodsSearch.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//
import Foundation

@objcMembers open class PaymentMethodSearch: NSObject {

    var groups: [PaymentMethodSearchItem]!
    var paymentMethods: [PaymentMethod]!
    var customerPaymentMethods: [CardInformation]?
    var cards: [Card]?
    var defaultOption: PaymentMethodSearchItem?

    func getPaymentOptionsCount() -> Int {
        let customOptionsCount = (self.customerPaymentMethods != nil) ? self.customerPaymentMethods!.count : 0
        let groupsOptionsCount = (self.groups != nil) ? self.groups!.count : 0
        return customOptionsCount + groupsOptionsCount
    }

    open class func fromJSON(_ json: NSDictionary) -> PaymentMethodSearch {
        let pmSearch = PaymentMethodSearch()
        var groups = [PaymentMethodSearchItem]()
        if let groupsJson = json["groups"] as? NSArray {
            for i in 0..<groupsJson.count {
                if let groupDic = groupsJson[i] as? NSDictionary {
                    groups.append(PaymentMethodSearchItem.fromJSON(groupDic))
                }
            }
            pmSearch.groups = groups
        }

        var paymentMethods = [PaymentMethod]()
        if let paymentMethodsJson = json["payment_methods"] as? NSArray {
            for i in 0..<paymentMethodsJson.count {
                if let paymentMethodsDic = paymentMethodsJson[i] as? NSDictionary {
                    let currentPaymentMethod = PaymentMethod.fromJSON(paymentMethodsDic)
                    paymentMethods.append(currentPaymentMethod)
                }
            }
            pmSearch.paymentMethods = paymentMethods
        }

        let customerCards = NSMutableDictionary()
        if let customerCardJson = json["cards"] as? NSArray {
            for i in 0..<customerCardJson.count {
                if let customerCardJsonDic = customerCardJson[i] as? NSDictionary {
                    let customerCardObject = Card.fromJSON(customerCardJsonDic)
                    customerCards.setValue(customerCardObject, forKey: String(describing: customerCardObject.idCard))
                }
            }
            pmSearch.cards = customerCards.allValues as? [Card]
        }

        var customerPaymentMethods = [CustomerPaymentMethod]()

        if let customerPaymentMethodsJson = json["custom_options"] as? NSArray {
            for i in 0..<customerPaymentMethodsJson.count {
                if let customerPaymentMethodDic = customerPaymentMethodsJson[i] as? NSDictionary {
                    let currentCustomerPaymentMethod = CustomerPaymentMethod.fromJSON(customerPaymentMethodDic)
                    customerPaymentMethods.append(currentCustomerPaymentMethod)
                    if let card = customerCards.value(forKey: currentCustomerPaymentMethod.getCardId()) as? Card {
                        currentCustomerPaymentMethod.card = card
                    }
                }
            }
            pmSearch.customerPaymentMethods = customerPaymentMethods
        }

        if let defaultPaymentMethodIdJson = json["default_option"] as? NSDictionary {
            let defaultPaymentMethodOption = PaymentMethodSearchItem.fromJSON(defaultPaymentMethodIdJson)
            pmSearch.defaultOption = defaultPaymentMethodOption
        }
        return pmSearch
    }
}
