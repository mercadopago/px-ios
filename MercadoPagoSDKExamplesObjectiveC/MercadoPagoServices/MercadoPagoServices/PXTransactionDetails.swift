//
//  PXTransactionDetails.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXTransactionDetails: NSObject {
    open var externalResourceUrl: String!
    open var financialInstitution: String!
    open var installmentAmount: Double!
    open var netReivedAmount: Double!
    open var overpaidAmount: Double!
    open var totalPaidAmount: Double!
    open var paymentMethodReferenceId: String!

}
