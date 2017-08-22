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
    public var decorationPreference = DecorationPreference()
    public var servicePreference = ServicePreference()
    public var checkoutPreference = CheckoutPreference()
    public var site: String = ""
    public var startFor: String = ""

    open class func fromJson(_ json: NSDictionary) -> CheckoutConfig {
        let config = CheckoutConfig()

        let startFor: String = json["start_for"] != nil ?  json["start_for"] as! String : ""
        let PK: String = json["public_key"] != nil ?  json["public_key"] as! String : ""
        let accessToken: String = json["access_token"] != nil ?  json["access_token"] as! String : ""
        let site: String = json["site_id"] != nil ?  json["site_id"] as! String : ""

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

        if let servicePreferenceDic = json["service_preference"] as? NSDictionary {
            config.servicePreference = ServicePreference.fromJSON(servicePreferenceDic)
        }

        if let decorationPreferenceDic = json["decoration_preference"] as? NSDictionary {
            config.decorationPreference = DecorationPreference.fromJSON(decorationPreferenceDic)
        }

        return config
    }

}
