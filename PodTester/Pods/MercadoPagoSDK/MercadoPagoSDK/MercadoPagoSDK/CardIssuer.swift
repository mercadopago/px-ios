//
//  CardIssuer.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

open class CardIssuer : NSObject {
    open var _id : String!
    open var name : String!
    open var labels : [String]!
    
    public init (_id: String, name: String?, labels: [String]) {
        super.init()
        self._id = _id
        self.name = name
        self.labels = labels
    }
}
