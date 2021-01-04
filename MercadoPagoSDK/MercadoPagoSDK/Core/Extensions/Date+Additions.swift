//
//  Date+Additions.swift
//  MercadoPagoPXTracking
//
//  Created by Eden Torres on 3/12/18.
//  Copyright © 2018 Mercado Pago. All rights reserved.
//

import Foundation
internal extension Date {
    func stringDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}
