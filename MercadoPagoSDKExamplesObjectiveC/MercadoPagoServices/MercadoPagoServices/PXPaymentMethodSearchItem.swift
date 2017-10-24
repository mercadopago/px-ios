//
//  PXPaymentMethodSearchItem.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPaymentMethodSearchItem: NSObject {
    open var id: String!
    open var type: PXPaymentMethodSearchItemType!
    open var _description: String!
    open var comment: String!
    open var children: [PXPaymentMethodSearchItem]!
    open var childrenHeader: String!
    open var showIcon: Bool!

}
