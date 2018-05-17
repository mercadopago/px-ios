//
//  IdentificationType.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 2/2/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

@objcMembers open class IdentificationType: NSObject {
    open var identificationTypeId: String?
    open var name: String?
    open var type: String?
    open var minLength: Int = 0
    open var maxLength: Int = 0

    open class func fromJSON(_ json: NSDictionary) -> IdentificationType {
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

    open func toJSONString() -> String {

        let identificationTypeId: Any = self.identificationTypeId != nil ? JSONHandler.null : self.identificationTypeId!
        let name: Any = self.name == nil ? JSONHandler.null : self.name!
        let type: Any = self.type == nil ? JSONHandler.null : self.type!
        let obj: [String: Any] = [
            "id": identificationTypeId,
            "name": name,
            "type": type,
            "min_length": self.minLength,
            "max_length": self.maxLength
        ]
        return JSONHandler.jsonCoding(obj)
    }
}

public func == (obj1: IdentificationType, obj2: IdentificationType) -> Bool {

    let areEqual =
        obj1.identificationTypeId == obj2.identificationTypeId &&
        obj1.name == obj2.name &&
        obj1.type == obj2.type &&
        obj1.minLength == obj2.minLength &&
        obj1.maxLength == obj2.maxLength

    return areEqual
}
