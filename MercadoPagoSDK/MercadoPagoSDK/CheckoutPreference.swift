//
//  CheckoutPreference.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 12/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class CheckoutPreference : NSObject {
    
    open var _id : String!
    open var items : [Item]? // que el conjunto no sea nulo y que no este vacio, que todos los items tengan la misma currency
                               // que cada item no sea nulo, que su cantidad sea 1 o mayor
                                // que el precio no sea nulo, ni menor o igual a cero
                                // currency no nula
                                // sean monedas conocidas (argentina, brasil, chile, colombia, mexico, venezuela y eeuu)
    open var payer : Payer!
    open var paymentPreference : PaymentPreference! //installments = sea mayor a cero y que el defaults_istallment sea mayor a 0
                                                        // excluded_payment_method < payment_methods
                                                        //excluded_payment_types < payment_types
    
    
    open var siteId : String = "MLA"
    
    
    open var choImage : UIImage?
    
    //shipments
    
    open func validate() -> String?{
    
    
        if(items == nil){
            return "No hay items".localized
        }
        if(items?.count == 0){
            return "No hay items".localized
        }
        //VALIDAR CADA ITEM
        let currencyIdAllItems = items![0].currencyId
        for (_, value) in items!.enumerated() {
            if(value.currencyId != currencyIdAllItems){
                 return "Los items tienen diferente moneda".localized
            }
        }
        
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
    
    
    open class func fromJSON(_ json : NSDictionary) -> CheckoutPreference {
        let preference : CheckoutPreference = CheckoutPreference()
        
        if let _id = JSONHandler.attemptParseToString(json["id"]){
            preference._id = _id
        }
        if let siteId = JSONHandler.attemptParseToString(json["site_id"]){
            preference.siteId = siteId
        }

        if let playerDic = json["payer"] as? NSDictionary {
            preference.payer = Payer.fromJSON(playerDic)
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
    
    
    open func loadingImageWithCallback(_ callback :((Void) -> Void)? = nil) -> Bool {
        
        if (choImage != nil){
            return false
        }
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            self.choImage = ViewUtils.loadImageFromUrl(self.getPictureUrl())
            DispatchQueue.main.async(execute: {
                if (callback != nil){
                    callback!()
                }
            })
        })
        return true
        
    }
    
    
    open func toJSONString() -> String {
        
        let _id : Any = self._id == nil ? JSONHandler.null : (self._id)!
        let player : Any = self.payer == nil ? JSONHandler.null : self.payer.toJSONString()
        var obj:[String:Any] = [
            "id": _id,
            "payer": player
        ]
        
        var itemsJson = ""
        for item in items! {
            itemsJson = itemsJson + item.toJSONString()
        }
        obj["items"] = itemsJson
        
        return JSONHandler.jsonCoding(obj)
    }
    
    open func getAmount() -> Double {
        var amount = 0.0
        for item in self.items! {
            amount = amount + (Double(item.quantity) * item.unitPrice)
        }
        return amount
    }
    
    open func getInstallments() -> Int {
        if self.paymentPreference != nil {
            if (self.paymentPreference!.maxAcceptedInstallments > 0) {
                return self.paymentPreference!.maxAcceptedInstallments
            } else if (self.paymentPreference!.defaultInstallments > 0) {
                return self.paymentPreference!.defaultInstallments
            }
        }
        return 1
    }
    
    
    open func getPaymentPreference () -> PaymentPreference {
        let paymentPreference = PaymentPreference()
        paymentPreference.excludedPaymentMethodIds = self.getExcludedPaymentMethodsIds()
        paymentPreference.excludedPaymentTypeIds = self.getExcludedPaymentTypesIds()
        paymentPreference.defaultPaymentMethodId = self.getDefaultPaymentMethodId()
        paymentPreference.maxAcceptedInstallments = self.getMaxAcceptedInstallments()
        paymentPreference.defaultInstallments = self.getDefaultInstallments()
        return paymentPreference
    }
    
    open func getExcludedPaymentTypesIds() -> Set<String>? {
        if (self.paymentPreference != nil && self.paymentPreference!.excludedPaymentTypeIds != nil) {
            return self.paymentPreference!.excludedPaymentTypeIds
        }
        return nil
    }
    
    open func getDefaultInstallments() -> Int {
        if (self.paymentPreference != nil && self.paymentPreference!.defaultInstallments > 0) {
            return self.paymentPreference!.defaultInstallments
        }
        return 0
    }
    
    open func getMaxAcceptedInstallments() -> Int {
        if (self.paymentPreference != nil && self.paymentPreference!.maxAcceptedInstallments > 0) {
            return self.paymentPreference!.maxAcceptedInstallments
        }
        return 0
    }
    
    open func getExcludedPaymentMethodsIds() -> Set<String>? {
        if (self.paymentPreference != nil && self.paymentPreference!.excludedPaymentMethodIds != nil) {
            return self.paymentPreference!.excludedPaymentMethodIds
        }
        return nil
    }

    open func getDefaultPaymentMethodId() -> String? {
        if (self.paymentPreference != nil && self.paymentPreference!.defaultPaymentMethodId != nil && self.paymentPreference!.defaultPaymentMethodId!.isNotEmpty) {
            return self.paymentPreference!.defaultPaymentMethodId
        }
        return nil
    }
    
    open func getTitle() -> String {
        
        if self.items!.count > 1 {
            var title = self.items!.reduce("", { (result, element) -> String in
                return element.title + ", " + result
            })
            let index = title.index(title.endIndex, offsetBy: -2)
            title.remove(at: index)
            return title
        }
        
        return self.items![0].title
    }
    
    open func getCurrencyId() -> String {
        return self.items![0].currencyId
    }
    
    open func getPictureUrl() -> String {
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



