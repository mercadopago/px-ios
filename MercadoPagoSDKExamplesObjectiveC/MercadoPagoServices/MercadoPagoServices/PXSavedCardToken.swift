//
//  PXSavedCardToken.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXSavedCardToken: NSObject {

    open var cardId: String!
    open var securityCode: String!
    open var device: PXDevice!
}
