//
//  Individual.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/27/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class Individual: Payer {

    var name: String!
    var lastName: String!

    public init(_id: String? = nil, email: String = "", identification: Identification? = nil, name: String, lastName: String) {
        super.init(_id: _id, email: email, identification: identification)
        self.name = name
        self.lastName = lastName
    }
}
