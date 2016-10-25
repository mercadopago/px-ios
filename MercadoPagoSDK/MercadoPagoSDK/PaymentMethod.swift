//
//  PaymentMethod.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class PaymentMethod : NSObject  {
    
    open var _id : String!

    open var name : String!
    open var paymentTypeId : String!
    open var settings : [Setting]!
    open var additionalInfoNeeded : [String]!
    open var accreditationTime : Int?
    
    public override init(){
        super.init()
    }
    
    open func isIssuerRequired() -> Bool {
        return isAdditionalInfoNeeded("issuer_id")
    }
    
    open func isIdentificationRequired() -> Bool {
        return isAdditionalInfoNeeded("cardholder_identification_number")
    }
    open func isIdentificationTypeRequired() -> Bool {
        return isAdditionalInfoNeeded("cardholder_identification_type")
    }
    
    open func isCard() -> Bool {
        let paymentTypeId = PaymentTypeId(rawValue : self.paymentTypeId)
        return paymentTypeId != nil && (paymentTypeId?.isCard())!
    }
    
    open func isSecurityCodeRequired(_ bin: String) -> Bool {
        
        let setting : Setting? = Setting.getSettingByBin(settings, bin: bin)
        if setting != nil && setting!.securityCode.length != 0 {
            return true
        } else {
            return false
        }
    }
    
    open func isAdditionalInfoNeeded(_ param: String!) -> Bool {
        if additionalInfoNeeded != nil && additionalInfoNeeded.count > 0 {
            for info in additionalInfoNeeded {
                if info == param {
                    return true
                }
            }
        }
        return false
    }
    
    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }
    
    open func toJSON() -> [String:Any] {
        let id : Any = String.isNullOrEmpty(self._id) ?  JSONHandler.null : self._id!
        let name : Any = self.name == nil ?  JSONHandler.null : self.name
        let payment_type_id : Any = self.paymentTypeId == nil ? JSONHandler.null : self.paymentTypeId
        
        let obj:[String:Any] = [
            "id": id,
            "name" : name,
            "payment_type_id" : payment_type_id,
            ]
        return obj
    }
    
    
    open class func fromJSON(_ json : NSDictionary) -> PaymentMethod {
        let paymentMethod : PaymentMethod = PaymentMethod()
        paymentMethod._id = json["id"] as? String
        paymentMethod.name = json["name"] as? String

		if json["payment_type_id"] != nil && !(json["payment_type_id"]! is NSNull) {
			paymentMethod.paymentTypeId = json["payment_type_id"] as! String
		}
		
        var settings : [Setting] = [Setting]()
        if let settingsArray = json["settings"] as? NSArray {
            for i in 0..<settingsArray.count {
                if let settingDic = settingsArray[i] as? NSDictionary {
                    settings.append(Setting.fromJSON(settingDic))
                }
            }
        }
        paymentMethod.settings = settings
        var additionalInfoNeeded : [String] = [String]()
        if let additionalInfoNeededArray = json["additional_info_needed"] as? NSArray {
            for i in 0..<additionalInfoNeededArray.count {
                if let additionalInfoNeededStr = additionalInfoNeededArray[i] as? String {
                    additionalInfoNeeded.append(additionalInfoNeededStr)
                }
            }
        }
        
        if let accreditationTime = json["accreditation_time"] as? Int {
            paymentMethod.accreditationTime = accreditationTime
        }
        
        
        paymentMethod.additionalInfoNeeded = additionalInfoNeeded
        return paymentMethod
    }
    
    open func conformsToBIN(_ bin : String) -> Bool {
        return (Setting.getSettingByBin(self.settings, bin: bin) != nil)
    }
    open func cloneWithBIN(_ bin : String) -> PaymentMethod? {
        let paymentMethod : PaymentMethod = PaymentMethod()
        paymentMethod._id = self._id
        paymentMethod.name = self.name
        paymentMethod.paymentTypeId = self.paymentTypeId
        paymentMethod.additionalInfoNeeded = self.additionalInfoNeeded
        if(Setting.getSettingByBin(self.settings, bin: bin) != nil){
            paymentMethod.settings = [Setting.getSettingByBin(self.settings, bin: bin)!]
            return paymentMethod
        }else{
            return nil
        }
    }
    
    open func isAmex() -> Bool{
        return self._id == "amex"
    }
    
    open func secCodeMandatory() -> Bool {
        if (self.settings.count == 0){
            return false // Si no tiene settings el codigo no es mandatorio
        }
        let filterList = self.settings.filter({ return $0.securityCode.mode == self.settings[0].securityCode.mode })
        if (filterList.count == self.settings.count){
            return self.settings[0].securityCode.mode == "mandatory"
        }else{
            return true // si para alguna de sus settings es mandatorio entonces el codigo es mandatorio
        }
    }
    
    open func secCodeLenght() -> Int {
        if (self.settings != nil && self.settings.count == 0 || self.settings == nil){
            return 3 //Si no tiene settings la longitud es cero
        }
        let filterList = self.settings.filter({ return $0.securityCode.length == self.settings[0].securityCode.length })
        if (filterList.count == self.settings.count){
            return self.settings[0].securityCode.length
        }else{
            return 0 //si la longitud de sus codigos, en sus settings no es siempre la misma entonces responde 0
        }
    }
    open func cardNumberLenght() -> Int {
        if (self.settings.count == 0){
            return 0 //Si no tiene settings la longitud es cero
        }
        let filterList = self.settings.filter({ return $0.cardNumber.length == self.settings[0].cardNumber.length })
        if (filterList.count == self.settings.count){
            return self.settings[0].cardNumber.length
        }else{
            return 0 //si la longitud de sus numberos, en sus settings no es siempre la misma entonces responde 0
        }
    }
    
    open func secCodeInBack() -> Bool {
        if (self.settings.count == 0){
            return true //si no tiene settings, por defecto el codigo de seguridad ira atras
        }
        let filterList = self.settings.filter({ return $0.securityCode.cardLocation == self.settings[0].securityCode.cardLocation })
        if (filterList.count == self.settings.count){
            return self.settings[0].securityCode.cardLocation == "back"
        }else{
            return true //si sus settings no coinciden el codigo ira atras por default
        }
    }
    
    open func isOnlinePaymentMethod() -> Bool {
        return self.isCard() || self.isAccountMoney()
    }
    
    open func isVISA() -> Bool {
        return ((self._id == "visa") && (self._id == "debvisa"))
    }
    
    open func isMASTERCARD() -> Bool {
        return ((self._id == "master") && (self._id == "debmaster"))
    }
    
    open func isAccountMoney() -> Bool {
        return (self._id == "account_money")
    }

    open func conformsPaymentPreferences(_ paymentPreference : PaymentPreference?) -> Bool{
        
        if(paymentPreference == nil){
            return true
        }
        if(paymentPreference!.defaultPaymentTypeId != nil){
            if (paymentPreference!.defaultPaymentTypeId != self.paymentTypeId){
                return false
            }
        }
        if (paymentPreference!.defaultPaymentMethodId != nil){
            if (self._id != paymentPreference!.defaultPaymentMethodId){
                return false
            }
        }
        if((paymentPreference?.excludedPaymentTypeIds) != nil){
            for (_, value) in (paymentPreference?.excludedPaymentTypeIds!.enumerated())! {
                if (value == self.paymentTypeId){
                    return false
                }
            }
        }
        
        if((paymentPreference?.excludedPaymentMethodIds) != nil){
            for (_, value) in (paymentPreference?.excludedPaymentMethodIds!.enumerated())! {
                if (value == self._id){
                    return false
                }
            }
        }
        
        
        return true
    }
    
    
    open func getColor()-> UIColor? {
     return MercadoPago.getColorFor(self)
    }
    open func getImage()-> UIImage? {
      return MercadoPago.getImageFor(self)
    }
    open func getLabelMask()-> String? {
        return MercadoPago.getLabelMaskFor(self)
    }
    open func getEditTextMask()-> String? {
        return MercadoPago.getEditTextMaskFor(self)
    }



}




public func ==(obj1: PaymentMethod, obj2: PaymentMethod) -> Bool {
    
    let areEqual =
    obj1._id == obj2._id &&
    obj1.name == obj2.name &&
    obj1.paymentTypeId == obj2.paymentTypeId &&
    obj1.settings == obj2.settings &&
    obj1.additionalInfoNeeded == obj2.additionalInfoNeeded
    
    return areEqual
}

