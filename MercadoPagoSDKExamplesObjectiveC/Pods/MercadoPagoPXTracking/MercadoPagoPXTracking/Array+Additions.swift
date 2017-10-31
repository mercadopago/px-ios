//
//  Array+Additions.swift
//  MercadoPagoPXTracking
//
//  Created by Eden Torres on 10/30/17.
//  Copyright © 2017 Mercado Pago. All rights reserved.
//

import Foundation
extension Array {
    public mutating func safeRemoveLast(_ suffix: Int) {
        if suffix > self.count {
            self.removeAll()
        } else {
            self.removeLast(suffix)
        }
    }

    public mutating func safeRemoveFirst(_ suffix: Int) {
        if suffix > self.count {
            self.removeAll()
        } else {
            self.removeFirst(suffix)
        }
    }
}
