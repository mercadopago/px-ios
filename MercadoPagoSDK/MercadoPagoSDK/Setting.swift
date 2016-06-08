//
//  Setting.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

public class Setting : NSObject {
    public var binMask : BinMask!
    public var cardNumber : CardNumber!
    public var securityCode : SecurityCode!
    
    public override init(){
        super.init()
    }
    
    public class func getSettingByBin(settings: [Setting]!, bin: String!) -> Setting? {
        var selectedSetting : Setting? = nil
        if settings != nil && settings.count > 0 {
            for setting in settings {
                
                if "" != bin && Regex(setting.binMask!.pattern! + ".*").test(bin) &&
                    (String.isNullOrEmpty(setting.binMask!.exclusionPattern) || !Regex(setting.binMask!.exclusionPattern! + ".*").test(bin!)) {
                    selectedSetting = setting
                }
            }
        }
        return selectedSetting
    }
    
    public class func fromJSON(json : NSDictionary) -> Setting {
        let setting : Setting = Setting()
        setting.binMask = BinMask.fromJSON(json["bin"]!  as! NSDictionary)
        if json["card_number"] != nil && !(json["card_number"]! is NSNull) {
            setting.cardNumber = CardNumber.fromJSON(json["card_number"]! as! NSDictionary)
        }
        setting.securityCode = SecurityCode.fromJSON(json["security_code"]! as! NSDictionary)
        return setting
    }
}

public func ==(obj1: Setting, obj2: Setting) -> Bool {
    
    let areEqual =
    obj1.binMask == obj2.binMask &&
    obj1.cardNumber == obj2.cardNumber &&
    obj1.securityCode == obj2.securityCode
    
    return areEqual
}