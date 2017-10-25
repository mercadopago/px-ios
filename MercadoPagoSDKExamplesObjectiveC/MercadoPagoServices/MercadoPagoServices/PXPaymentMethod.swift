//
//  PXPaymentMethod.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPaymentMethod: NSObject {
    open var additionalInfoNeeded: [String]!
    open var id: String!
    open var name: String!
    open var paymentTypeId: String!
    open var status: String!
    open var secureThumbnail: String!
    open var thumbnail: String!
    open var deferredCapture: String!
    open var settings: [PXSetting]!
    open var minAllowedAmount: Double!
    open var maxAllowedAmount: Double!
    open var accreditationTime: Int!
    open var merchantAccountId: String!
    open var financialInstitutions: [PXFinancialInstitution]!

    open class func fromJSON(_ json: NSDictionary) -> PXPaymentMethod {
        let paymentMethod: PXPaymentMethod = PXPaymentMethod()
        return paymentMethod
    }

}
