//
//  PXInstallment.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXInstallment: NSObject {
    open var issuer: PXIssuer!
    open var payerCosts: [PXPayerCost]!
    open var paymentMethodId: String!
    open var paymentType: String!

    open class func fromJSON(_ json: NSDictionary) -> PXInstallment {
        let paymentMethod: PXInstallment = PXInstallment()
        return paymentMethod
    }

}
