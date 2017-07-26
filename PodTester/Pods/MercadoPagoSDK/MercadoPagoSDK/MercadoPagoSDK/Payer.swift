//
//  Payer.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

open class Payer: NSObject {
	open var email: String!
	open var _id: String?
	open var identification: Identification?
    open var entityType: EntityType?

    public init(_id: String? = nil, email: String = "", type: String? = nil, identification: Identification? = nil, entityType: EntityType? = nil) {
		self._id = _id
		self.email = email
		self.identification = identification
        self.entityType = entityType
	}

    func clearCollectedData() {
        self.entityType = nil
        self.identification = nil
    }

	open class func fromJSON(_ json: NSDictionary) -> Payer {
		let payer: Payer = Payer()
		if let _id = JSONHandler.attemptParseToString(json["id"]) {
			payer._id  = _id
		}
		if let email = JSONHandler.attemptParseToString(json["email"]) {
			payer.email  = email
		}

		if let identificationDic = json["identification"] as? NSDictionary {
			payer.identification = Identification.fromJSON(identificationDic)
		}

        if let entityTypeDic = json["entity_type"] as? NSDictionary {
            payer.entityType = EntityType.fromJSON(entityTypeDic)
        }

		return payer
	}

	open func toJSONString() -> String {
		return JSONHandler.jsonCoding(toJSON())
	}

    open func toJSON() -> [String:Any] {
        let email : Any = self.email == nil ? JSONHandler.null : (self.email!)
//        let identification : Any = self.identification == nil ? JSONHandler.null : self.identification!.toJSONString()
//        let entityType : Any = self.entityType == nil ? JSONHandler.null : self.entityType!.toJSONString()
        var obj: [String:Any] = [
            "email": email,
        ]

        if self._id != nil {
            obj["id"] = self._id
        }

        if self.identification != nil {
            obj["identification"] = self.identification?.toJSON()
        }

        if let ET = self.entityType {
            obj["entity_type"] = ET._id
        }

        return obj
    }

}

public class GroupsPayer: Payer {

    open override func toJSON() -> [String:Any] {
        var payerObj: [String:Any]  = super.toJSON()
        payerObj["access_token"] = MercadoPagoContext.payerAccessToken()
        return payerObj
    }

}

public func ==(obj1: Payer, obj2: Payer) -> Bool {

	let areEqual =
		obj1._id == obj2._id &&
			obj1.email == obj2.email &&
			obj1.identification == obj2.identification &&
            obj1.entityType == obj2.entityType

	return areEqual
}
