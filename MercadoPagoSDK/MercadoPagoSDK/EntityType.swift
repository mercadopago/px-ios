//
//  EntityType.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 3/9/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class EntityType: NSObject, Cellable {

    public var objectType: ObjectTypes = ObjectTypes.entityType
    open var entityTypeId: String!
    open var name: String!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    open func toJSON() -> [String: Any] {
        let id: Any = self.entityTypeId == nil ? JSONHandler.null : self.entityTypeId!
        let name: Any = self.name == nil ? JSONHandler.null : self.name!
        let obj: [String: Any] = [
            "id": id,
            "name": name
            ]
        return obj
    }
}

public func == (obj1: EntityType, obj2: EntityType) -> Bool {

    let areEqual =
        obj1.entityTypeId == obj2.entityTypeId &&
            obj1.name == obj2.name

    return areEqual
}
