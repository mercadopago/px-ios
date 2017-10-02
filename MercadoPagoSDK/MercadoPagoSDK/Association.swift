//
//  Association.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/27/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class Association: Payer {

    var businessName: String!
    public init(_id: String? = nil, email: String = "", identification: Identification? = nil, businessName: String) {
        super.init(_id: _id, email: email, identification: identification)
        self.businessName = businessName
    }

}
