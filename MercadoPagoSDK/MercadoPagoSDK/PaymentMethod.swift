//
//  PaymentMethod.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

public class PaymentMethod : Equatable  {
    
    public var _id : String!

    public var name : String!
    public var paymentTypeId : PaymentTypeId!
    public var settings : [Setting]!
    public var additionalInfoNeeded : [String]!
    public var accreditationTime : Int?
    
    public func isIssuerRequired() -> Bool {
        return isAdditionalInfoNeeded("issuer_id")
    }
    
    public func isIdentificationRequired() -> Bool {
        return isAdditionalInfoNeeded("cardholder_identification_number")
    }
    public func isIdentificationTypeRequired() -> Bool {
        return isAdditionalInfoNeeded("cardholder_identification_type")
    }
    
    public func isSecurityCodeRequired(bin: String) -> Bool {
        
        let setting : Setting? = Setting.getSettingByBin(settings, bin: bin)
        if setting != nil && setting!.securityCode.length != 0 {
            return true
        } else {
            return false
        }
    }
    
    public func isAdditionalInfoNeeded(param: String!) -> Bool {
        if additionalInfoNeeded != nil && additionalInfoNeeded.count > 0 {
            for info in additionalInfoNeeded {
                if info == param {
                    return true
                }
            }
        }
        return false
    }
    
    public class func fromJSON(json : NSDictionary) -> PaymentMethod {
        let paymentMethod : PaymentMethod = PaymentMethod()
        paymentMethod._id = JSON(json["id"]!).asString
        paymentMethod.name = JSON(json["name"]!).asString

		if json["payment_type_id"] != nil && !(json["payment_type_id"]! is NSNull) {
			paymentMethod.paymentTypeId = PaymentTypeId(rawValue: json["payment_type_id"] as! String)
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
    
    public func conformsToBIN(bin : String) -> Bool {
        return (Setting.getSettingByBin(self.settings, bin: bin) != nil)
    }
    public func cloneWithBIN(bin : String) -> PaymentMethod? {
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
    
    public func isAmex() -> Bool{
        return self._id == "amex"
    }
    
    public func secCodeMandatory() -> Bool {
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
    
    public func secCodeLenght() -> Int {
        if (self.settings.count == 0){
            return 0 //Si no tiene settings la longitud es cero
        }
        let filterList = self.settings.filter({ return $0.securityCode.length == self.settings[0].securityCode.length })
        if (filterList.count == self.settings.count){
            return self.settings[0].securityCode.length
        }else{
            return 0 //si la longitud de sus codigos, en sus settings no es siempre la misma entonces responde 0
        }
    }
    
    public func secCodeInBack() -> Bool {
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
    
    
    public func isOfflinePaymentMethod() -> Bool {
        return self.paymentTypeId != nil && self.paymentTypeId.isOfflinePayment()
    }
    
    
    public func isVISA() -> Bool {
        return ((self._id == "visa") && (self._id == "debvisa"))
    }
    public func isMASTERCARD() -> Bool {
        return ((self._id == "master") && (self._id == "debmaster"))
    }

    public func conformsPaymentPreferences(paymentPreference : PaymentPreference?) -> Bool{
        
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
            for (_, value) in (paymentPreference?.excludedPaymentTypeIds!.enumerate())! {
                if (value == self.paymentTypeId){
                    return false
                }
            }
        }
        
        if((paymentPreference?.excludedPaymentMethodIds) != nil){
            for (_, value) in (paymentPreference?.excludedPaymentMethodIds!.enumerate())! {
                if (value == self._id){
                    return false
                }
            }
        }
        
        
        return true
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

