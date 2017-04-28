//
//  ApiException.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 25/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

open class ApiException : NSObject {
    open var cause : Cause!
    open var error : String!
    open var message : String!
    open var status : Int = 0
}
