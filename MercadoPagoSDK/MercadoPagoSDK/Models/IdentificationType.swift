//
//  IdentificationType.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 2/2/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

/** :nodoc: */
@available(*, deprecated, message: "Not used in any flow")
@objcMembers open class IdentificationType: NSObject {
    open var identificationTypeId: String?
    open var name: String?
    open var type: String?
    open var minLength: Int = 0
    open var maxLength: Int = 0

    internal class func fromJSON(_ json: NSDictionary) -> IdentificationType {
                let identificationType: IdentificationType = IdentificationType()
                if let identificationTypeId = JSONHandler.attemptParseToString(json["id"]) {
                        identificationType.identificationTypeId = identificationTypeId
                    }
                if let name = JSONHandler.attemptParseToString(json["name"]) {
                        identificationType.name = name
                    }
                if let type = JSONHandler.attemptParseToString(json["type"]) {
                        identificationType.type = type
                    }
                if let minLength = JSONHandler.attemptParseToInt(json["min_length"]) {
                        identificationType.minLength = minLength
                    }
                if let maxLength = JSONHandler.attemptParseToInt(json["max_length"]) {
                        identificationType.maxLength = maxLength
                    }
                return identificationType
        }
}
