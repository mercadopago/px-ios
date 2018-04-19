//
//  CheckoutPreference.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 12/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers open class CheckoutPreference: NSObject {

    open var preferenceId: String!
    open var items: [Item]!
    open var payer: Payer!
    open var paymentPreference: PaymentPreference!
    open var siteId: String = "MLA"
    open var expirationDateFrom: Date?
    open var expirationDateTo: Date?

    open class func fromJSON(_ json: NSDictionary) -> CheckoutPreference {
                let preference: CheckoutPreference = CheckoutPreference()

                if let _id = JSONHandler.attemptParseToString(json["id"]) {
                        preference.preferenceId = _id
                    }
                if let siteId = JSONHandler.attemptParseToString(json["site_id"]) {
                        preference.siteId = siteId
                    }

                if let payerDic = json["payer"] as? NSDictionary {
                        preference.payer = Payer.fromJSON(payerDic)
                    }

                var items = [Item]()
                if let itemsArray = json["items"] as? NSArray {
                        for i in 0..<itemsArray.count {
                                if let itemDic = itemsArray[i] as? NSDictionary {
                                        items.append(Item.fromJSON(itemDic))
                                }
                            }

                        preference.items = items
                    }

                if let paymentPreference = json["payment_methods"] as? NSDictionary {
                        preference.paymentPreference = PaymentPreference.fromJSON(paymentPreference)
                    }

                return preference
            }

    public init(preferenceId: String) {
        self.preferenceId = preferenceId
    }

    public init(items: [Item] = [], payer: Payer = Payer(), paymentMethods: PaymentPreference? = nil) {
        self.items = items
        self.payer = payer
        self.paymentPreference = paymentMethods ?? PaymentPreference()
    }

    public func addItem(item: Item) {
        items.append(item)
    }

    public func addItems(items: [Item]) {
        self.items.append(contentsOf: items)
    }

    public func addExcludedPaymentMethod(_ paymentMethodId: String) {
        if self.paymentPreference.excludedPaymentMethodIds != nil {
            self.paymentPreference.excludedPaymentMethodIds?.insert(paymentMethodId)
        } else {
            self.paymentPreference.excludedPaymentMethodIds = [paymentMethodId]
        }
    }
    public func setExcludedPaymentMethods(_ paymentMethodIds: Set<String>) {
        self.paymentPreference.excludedPaymentMethodIds = paymentMethodIds
    }

    public func addExcludedPaymentType(_ paymentTypeId: String) {
        if self.paymentPreference.excludedPaymentTypeIds != nil {
            self.paymentPreference.excludedPaymentTypeIds?.insert(paymentTypeId)
        } else {
            self.paymentPreference.excludedPaymentTypeIds = [paymentTypeId]
        }
    }

    public func setExcludedPaymentTypes(_ paymentTypeIds: Set<String>) {
        self.paymentPreference.excludedPaymentTypeIds = paymentTypeIds
    }

    public func setMaxInstallments(_ maxInstallments: Int) {
        self.paymentPreference.maxAcceptedInstallments = maxInstallments
    }

    public func setDefaultInstallments(_ defaultInstallments: Int) {
        self.paymentPreference.defaultInstallments = defaultInstallments
    }

    public func setDefaultPaymentMethodId(_ paymetMethodId: String) {
        self.paymentPreference.defaultPaymentMethodId = paymetMethodId
    }

    public func setPayerEmail(_ payerEmail: String) {
        self.payer.email = payerEmail
    }

    public func setSite(siteId: String) {
        self.siteId = siteId
    }

    public func setExpirationDate(_ expirationDate: Date) {
        self.expirationDateTo = expirationDate
    }

    public func setActiveFromDate(_ date: Date) {
        self.expirationDateFrom = date
    }

    public func setId(_ preferenceId: String) {
        self.preferenceId = preferenceId
    }

    public func getId() -> String {
        return self.preferenceId
    }

    public func getItems() -> [Item]? {
        return items
    }

    public func getPayer() -> Payer {
        return payer
    }

    public func getSiteId() -> String {
        return self.siteId
    }

    public func getExpirationDate() -> Date? {
        return expirationDateTo
    }

    public func getActiveFromDate() -> Date? {
        return expirationDateFrom
    }

    open func getExcludedPaymentTypesIds() -> Set<String>? {
        return paymentPreference.getExcludedPaymentTypesIds()
    }

    open func getDefaultInstallments() -> Int {
        return paymentPreference.getDefaultInstallments()
    }

    open func getMaxAcceptedInstallments() -> Int {
        return paymentPreference.getMaxAcceptedInstallments()
    }

    open func getExcludedPaymentMethodsIds() -> Set<String>? {
        return paymentPreference.getExcludedPaymentMethodsIds()
    }

    open func getDefaultPaymentMethodId() -> String? {
        return paymentPreference.getDefaultPaymentMethodId()
    }

    open func validate() -> String? {

        if let itemError = itemsValid() {
            return itemError
        }
        if self.payer == nil {
            return "No hay información de payer".localized
        }

        if self.payer.email == nil || self.payer.email?.count == 0 {
            return "Se requiere email de comprador".localized
        }

        if !isActive() {
            return "La preferencia no esta activa.".localized
        }

        if isExpired() {
            return "La preferencia esta expirada".localized
        }
        if self.getAmount() < 0 {
            return "El monto de la compra no es válido".localized
        }
        return nil
    }

    open func itemsValid() -> String? {
        if Array.isNullOrEmpty(items) {
            return "No hay items".localized
        }
        let currencyIdAllItems = items[0].currencyId

        for item in items {
            if item.currencyId != currencyIdAllItems {
                return "Los items tienen diferente moneda".localized
            }

            if let error = item.validate() {
                return error
            }
        }

        return nil
    }

    open func isExpired() -> Bool {
        let date = Date()
        if let expirationDateTo = expirationDateTo {
            return expirationDateTo > date
        }
        return false
    }

    open func isActive() -> Bool {
        let date = Date()
        if let expirationDateFrom = expirationDateFrom {
            return expirationDateFrom < date
        }
        return true
    }

    func hasMultipleItems() -> Bool {
        return items.count > 1
    }

    open func toJSONString() -> String {

        let _id: Any = self.preferenceId == nil ? JSONHandler.null : (self.preferenceId)!
        let player: Any = self.payer == nil ? JSONHandler.null : self.payer.toJSONString()
        var obj: [String: Any] = [
            "id": _id,
            "payer": player
        ]

        var itemsJson = ""
        for item in items {
            itemsJson += item.toJSONString()
        }
        obj["items"] = itemsJson

        return JSONHandler.jsonCoding(obj)
    }

    open func getAmount() -> Double {
        var amount = 0.0
        for item in self.items {
            amount += (Double(item.quantity) * item.unitPrice)
        }
        return amount
    }
}

public func == (obj1: CheckoutPreference, obj2: CheckoutPreference) -> Bool {

    let areEqual =
        obj1.preferenceId == obj2.preferenceId &&
            obj1.items == obj2.items &&
            obj1.payer == obj2.payer &&
            obj1.paymentPreference == obj2.paymentPreference

    return areEqual
}
