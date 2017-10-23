//
//  PXCheckoutPreference.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXCheckoutPreference: NSObject {
    open var id: String!
    open var item: [PXItem]!
    open var payer: PXPayer!
    open var paymentPreference: PXPaymentPreference!
    open var siteID: String!
    open var expirationDateTo: Date!
    open var expirationDateFrom: Date!
    open var site: PXSite!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {

    }

    open class func fromJSON(_ json: [String:Any]) -> PXCheckoutPreference {

    }
}
