//
//  CheckoutPreference.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 12/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class CheckoutPreference : Equatable {
    
    public var _id : String!
    public var items : [Item]? // que el conjunto no sea nulo y que no este vacio, que todos los items tengan la misma currency
                               // que cada item no sea nulo, que su cantidad sea 1 o mayor
                                // que el precio no sea nulo, ni menor o igual a cero
                                // currency no nula
                                // sean monedas conocidas (argentina, brasil, chile, colombia, mexico, venezuela y eeuu)
    public var payer : Payer!
    public var paymentPreference : PaymentPreference? //installments = sea mayor a cero y que el defaults_istallment sea mayor a 0
                                                        // excluded_payment_method < payment_methods
                                                        //excluded_payment_types < payment_types
    
    
    
    
    
    //shipments
    
    //DATE ACTIVE = expiration_date_from
    //DATE EXPIRATION = expiration_date_to
    // que el dia actual caiga en ese rango (de activacion) OJO!!! PUEDEN SER NULAS LAS FECHAS, en ese caso, no mueren nunca, y siempre es valida la preference
    
    public func validate() -> String?{
    
    
        if(items == nil){
            return "No hay items".localized
        }
        if(items?.count == 0){
            return "No hay items".localized
        }
        //VALIDAR CADA ITEM
        let currencyIdAllItems = items![0].currencyId
        for (_, value) in items!.enumerate() {
            if(value.currencyId != currencyIdAllItems){
                 return "Los items tienen diferente moneda".localized
            }
        }
        //validar precio item(!= nil & >0), y que la currency exista
        // que pref no esté expirada -> expirationDateTo
        // que pref esté activa -> dateFrom
        
        // que installments : sea null || > 0 
        // maxInstallments lo mismo
        //que no esten todos los payment types exluidos!
        
        
        
        //VALIDAR PREFERENCE PAYMENT METHOD
        
        if self.payer == nil {
            return "No hay información de payer".localized
        }
        
        if self.payer.email == nil || self.payer.email.characters.count == 0 {
            return "Se requiere email de comprador".localized
        }
        
        return nil
    }
    
    public init(items : [Item] = [], payer : Payer? = nil, paymentMethods : PaymentPreference? = nil){
        self.items = items
        self.payer = payer
        self.paymentPreference = paymentMethods
    }
    
    
    public class func fromJSON(json : NSDictionary) -> CheckoutPreference {
        let preference : CheckoutPreference = CheckoutPreference()
        
        if json["id"] != nil && !(json["id"]! is NSNull) {
            preference._id = (json["id"]! as? String)
        }
        
        if json["payer"] != nil && !(json["payer"]! is NSNull) {
            preference.payer = Payer.fromJSON(json["payer"]! as! NSDictionary)
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
        
        if json["payment_methods"] != nil && !(json["payment_methods"]! is NSNull) {
            let jsonPaymentPreference = json["payment_methods"] as! NSDictionary
            preference.paymentPreference = PaymentPreference.fromJSON(jsonPaymentPreference)
        }
        
        return preference
    }
    
    public func toJSONString() -> String {
        var obj:[String:AnyObject] = [
            "id": self._id == nil ? JSON.null : (self._id)!,
            "payer": self.payer == nil ? JSON.null : self.payer.toJSONString()
        ]
        
        var itemsJson = ""
        for item in items! {
            itemsJson = itemsJson + item.toJSONString()
        }
        obj["items"] = itemsJson
        
        return JSON(obj).toString()
    }
    
    public func getAmount() -> Double {
        var amount = 0.0
        for item in self.items! {
            amount = amount + (Double(item.quantity) * item.unitPrice)
        }
        return amount
    }
    
    public func getInstallments() -> Int {
        if self.paymentPreference != nil {
            if (self.paymentPreference!.maxAcceptedInstallments != nil) {
                return self.paymentPreference!.maxAcceptedInstallments!
            } else if (self.paymentPreference!.defaultInstallments != nil) {
                return self.paymentPreference!.defaultInstallments!
            }
        }
        return 1
    }
    
    
    public func getPaymentSettings () -> PaymentPreference {
        let settings = PaymentPreference(excludedPaymentMethodsIds: self.getExcludedPaymentMethodsIds(), excludedPaymentTypesIds: self.getExcludedPaymentTypesIds(), defaultPaymentMethodId: self.getDefaultPaymentMethodId(), maxAcceptedInstallment: self.getMaxAcceptedInstallments(), defaultInstallments: self.getDefaultInstallments())
        
        return settings
    }
    
    public func getExcludedPaymentTypesIds() -> Set<PaymentTypeId>? {
        if (self.paymentPreference != nil && self.paymentPreference!.excludedPaymentTypeIds != nil) {
            return self.paymentPreference!.excludedPaymentTypeIds
        }
        return nil
    }
    
    public func getDefaultInstallments() -> Int? {
        if (self.paymentPreference != nil && self.paymentPreference!.defaultInstallments != nil) {
            return self.paymentPreference!.defaultInstallments
        }
        return nil
    }
    
    public func getMaxAcceptedInstallments() -> Int? {
        if (self.paymentPreference != nil && self.paymentPreference!.maxAcceptedInstallments != nil) {
            return self.paymentPreference!.maxAcceptedInstallments
        }
        return nil
    }
    
    public func getExcludedPaymentMethodsIds() -> Set<String>? {
        if (self.paymentPreference != nil && self.paymentPreference!.excludedPaymentMethodIds != nil) {
            return self.paymentPreference!.excludedPaymentMethodIds
        }
        return nil
    }

    public func getDefaultPaymentMethodId() -> String? {
        if (self.paymentPreference != nil && self.paymentPreference!.defaultPaymentMethodId != nil && self.paymentPreference!.defaultPaymentMethodId!.isNotEmpty) {
            return self.paymentPreference!.defaultPaymentMethodId
        }
        return nil
    }
    
    public func getTitle() -> String {
        return self.items![0].title
    }
    
    public func getCurrencyId() -> String {
        return self.items![0].currencyId
    }
    
    public func getPictureUrl() -> String {
        return self.items![0].pictureUrl
    }
}

public func ==(obj1: CheckoutPreference, obj2: CheckoutPreference) -> Bool {
    
    let areEqual =
        obj1._id == obj2._id &&
        obj1.items! == obj2.items! &&
        obj1.payer == obj2.payer &&
        obj1.paymentPreference == obj2.paymentPreference
    
    return areEqual
}


