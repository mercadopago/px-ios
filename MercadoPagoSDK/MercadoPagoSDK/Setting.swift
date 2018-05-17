//
//  Setting.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

@objcMembers open class Setting: NSObject {
    open var binMask: BinMask!
    open var cardNumber: CardNumber!
    open var securityCode: SecurityCode!

    public override init() {
        super.init()
    }

    open class func fromJSON(_ json: NSDictionary) -> Setting {
                let setting: Setting = Setting()
                setting.binMask = BinMask.fromJSON(json["bin"]!  as! NSDictionary)
                if json["card_number"] != nil && !(json["card_number"]! is NSNull) {
                        setting.cardNumber = CardNumber.fromJSON(json["card_number"]! as! NSDictionary)
                    }
                setting.securityCode = SecurityCode.fromJSON(json["security_code"]! as! NSDictionary)
                return setting
            }

    open class func getSettingByBin(_ settings: [Setting]!, bin: String!) -> [Setting]? {
        var selectedSetting = [Setting] ()
        if settings != nil && settings.count > 0 {
            for setting in settings {

                if "" != bin && Regex(setting.binMask!.pattern! + ".*").test(bin) &&
                    (String.isNullOrEmpty(setting.binMask!.exclusionPattern) || !Regex(setting.binMask!.exclusionPattern! + ".*").test(bin!)) {
                    selectedSetting.append(setting)
                }
            }

        }
        return selectedSetting.isEmpty ? nil : selectedSetting
    }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String: Any] {
        let binMask: Any = self.binMask == nil ?  JSONHandler.null : self.binMask.toJSON()
        let cardNumber: Any = self.cardNumber == nil ?  JSONHandler.null : self.cardNumber.toJSON()
        let securityCode: Any = self.securityCode == nil ? JSONHandler.null : self.securityCode.toJSON()

        let obj: [String: Any] = [
            "bin": binMask,
            "card_number": cardNumber,
            "security_code": securityCode
        ]
        return obj
    }
}
