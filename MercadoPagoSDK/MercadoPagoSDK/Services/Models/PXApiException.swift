//
//  PXApiException.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
/// :nodoc:
open class PXApiException: NSObject, Codable {
    open var cause: [PXCause]?
    open var error: String?
    open var message: String?
    open var status: Int?
}
