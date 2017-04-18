//
//  Payer.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

open class Payer : NSObject {
	open var email : String!
	open var _id : String?
	open var identification : Identification?
	
	
	
	public init(_id : String? = nil, email: String = "", type : String? = nil, identification: Identification? = nil){
		self._id = _id
		self.email = email
		self.identification = identification
	}
	
	open class func fromJSON(_ json : NSDictionary) -> Payer {
		let payer : Payer = Payer()
		if let _id = JSONHandler.attemptParseToString(json["id"]) {
			payer._id  = _id
		}
		if let email = JSONHandler.attemptParseToString(json["email"]) {
			payer.email  = email
		}
		
		if let identificationDic = json["identification"] as? NSDictionary {
			payer.identification = Identification.fromJSON(identificationDic)
		}
		return payer
	}
	
	
	open func toJSONString() -> String {
		return JSONHandler.jsonCoding(toJSON())
	}
    
    open func toJSON() -> [String:Any] {
        let email : Any = self.email == nil ? JSONHandler.null : (self.email!)
        let _id : Any = self._id == nil ? JSONHandler.null : self._id
        let identification : Any = self.identification == nil ? JSONHandler.null : self.identification!.toJSONString()
        let obj:[String:Any] = [
            "email": email,
            "_id": _id,
            "identification" : identification
        ]
        return obj
    }
	
}

public class GroupsPayer : Payer {
    
    open override func toJSON() -> [String:Any] {
        var payerObj : [String:Any]  = super.toJSON()
        payerObj["access_token"] = MercadoPagoContext.payerAccessToken()
        return payerObj
    }

}

public func ==(obj1: Payer, obj2: Payer) -> Bool {
	
	let areEqual =
		obj1._id == obj2._id &&
			obj1.email == obj2.email &&
			obj1.identification == obj2.identification
	
	return areEqual
}

