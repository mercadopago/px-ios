//
//  PXSavedESCCardToken.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXSavedESCCardToken: PXSavedCardToken {
    open var requireEsc: Bool!
    open var esc: String!

    open override func toJSONString() -> String {
        super.toJSONString()
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open override func toJSON() -> [String:Any] {
        super.toJSON()
        let map = ["": ""]
        return map
    }

    open override class func fromJSON(_ json: [String:Any]) -> PXSavedESCCardToken {
        //super.fromJSON(<#T##json: [String : Any]##[String : Any]#>)
        return PXSavedESCCardToken()
    }
}
