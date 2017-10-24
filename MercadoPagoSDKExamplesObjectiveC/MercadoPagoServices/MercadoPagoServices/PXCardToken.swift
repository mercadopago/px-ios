//
//  PXCardToken.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXCardToken: NSObject {

    open var cardholder: PXCardHolder!
    open var cardNumber: String!
    open var device: PXDevice!
    open var expirationMonth: Int!
    open var expirationYear: Int!
    open var securityCode: String!

}
