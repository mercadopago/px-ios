//
//  Cause.swift
//  MercadoPagoSDK
//
//  Created by Mauro Reverter on 6/30/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class Cause: NSObject {
    open var code: String!
    open var _description: String!

    open class func fromJSON(_ json: NSDictionary) -> Cause {
        let cause: Cause = Cause()

        if let code = JSONHandler.attemptParseToString(json["code"]) {
            cause.code = code
        }

        if let description = JSONHandler.attemptParseToString(json["description"]) {
            cause._description = description
        }

        return cause
    }
}
