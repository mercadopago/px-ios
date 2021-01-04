//
//  Array+Additions.swift
//  MercadoPagoPXTracking
//
//  Created by Eden Torres on 10/30/17.
//  Copyright © 2017 Mercado Pago. All rights reserved.
//

import Foundation
internal extension Array {
    static func isNullOrEmpty(_ value: Array?) -> Bool {
        return value == nil || value?.count == 0
    }
}
