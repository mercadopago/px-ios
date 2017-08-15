//
//  CheckoutConfig.swift
//  PodTester
//
//  Created by Eden Torres on 8/14/17.
//  Copyright © 2017 AUGUSTO COLLERONE ALFONSO. All rights reserved.
//

import Foundation
import MercadoPagoSDK

open class CheckoutConfig: NSObject {

    public var publicKey: String = ""
    public var accessToken: String = ""
    public var flowPreference = FlowPreference()
    public let decorationPreference = DecorationPreference()
    public let servicePreference = ServicePreference()
    public var checkoutPreference = CheckoutPreference()
    public var site: String = ""
    public var startFor: String = ""

    open class func fromJson(_ json: NSDictionary) -> CheckoutConfig {
        let config = CheckoutConfig()

        let startFor: String = json["start_for"] != nil ?  json["start_for"] as! String : ""
        let PK: String = json["public_key"] != nil ?  json["public_key"] as! String : ""
        let accessToken: String = json["access_token"] != nil ?  json["access_token"] as! String : ""
        let site: String = json["site_id"] != nil ?  json["site_id"] as! String : ""

        //let prefID: String = json["pref_id"] != nil ?  json["pref_id"] as! String : ""
        //let payerEmail: String = json["payer_email"] != nil ?  json["payer_email"] as! String : ""
        //let items: [NSDictionary] = json["items"] != nil ?  json["items"] as! [NSDictionary] : []
        //let maxCards = json["show_max_saved_cards"] != nil ? json["show_max_saved_cards"] as? Int : nil

        config.startFor = startFor
        config.publicKey = PK
        config.accessToken = accessToken
        config.site = site

        if let flowPreferenceDic = json["flow_preference"] as? NSDictionary {
            config.flowPreference = FlowPreference.fromJSON(flowPreferenceDic)
        }

        if let checkoutPreferenceDic = json["checkout_preference"] as? NSDictionary {
            config.checkoutPreference = CheckoutPreference.fromJSON(checkoutPreferenceDic)
        }

        return config
    }

}
