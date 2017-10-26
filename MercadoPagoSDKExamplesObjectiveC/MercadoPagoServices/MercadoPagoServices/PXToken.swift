//
//  PXToken.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXToken: NSObject {
    open var id: String!
    open var publicKey: String!
    open var cardId: String!
    open var luhnValidation: String!
    open var status: String!
    open var usedDate: Date!
    open var cardNumberLength: Int!
    open var creationDate: Date!
    open var truncCardNumber: String!
    open var securityCodeLength: Int!
    open var expirationMonth: Int!
    open var expirationYear: Int!
    open var lastModifiedDate: Date!
    open var dueDate: Date!
    open var firstSixDigits: String!
    open var lastFourDigits: String!
    open var cardholder: PXCardHolder!
    open var esc: String!

    open class func fromJSON(_ json: NSDictionary) -> PXToken {
        let pxToken = PXToken()
        return pxToken
    }
}
