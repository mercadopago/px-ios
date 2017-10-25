//
//  PXDiscount.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXDiscount: NSObject {
    open var id: String!
    open var name: String!
    open var percentOff: Double!
    open var amountOff: Double!
    open var couponAmount: Double!
    open var currencyId: String!
    open var couponCode: String!
    open var concept: String!

    open class func fromJSON(_ json: NSDictionary) -> PXDiscount {
        let pxDiscount: PXDiscount = PXDiscount()
        return pxDiscount
    }
}
