//
//  Promo.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 22/5/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import Foundation

public class Promo : NSObject {
	
	public var promoId : String!
	public var issuer : Issuer!
	public var recommendedMessage : String!
	public var paymentMethods : [PaymentMethod]!
	public var legals : String!
	public var url : String!
	
	public class func fromJSON(json : NSDictionary) -> Promo {
		
		let promo : Promo = Promo()
        promo.promoId = json["id"] == nil ? "" : json["id"]?.stringValue
		
		if let issuerDic = json["issuer"] as? NSDictionary {
			promo.issuer = Issuer.fromJSON(issuerDic)
		}

        promo.recommendedMessage = json["recommended_message"] == nil ? "" : json["recommended_message"]!.stringValue
		
		if let picDic = json["picture"] as? NSDictionary {
			promo.url = picDic["url"] as? String
		}
		
		var paymentMethods : [PaymentMethod] = [PaymentMethod]()
		if let pmArray = json["payment_methods"] as? NSArray {
			for i in 0..<pmArray.count {
				if let pmDic = pmArray[i] as? NSDictionary {
					paymentMethods.append(PaymentMethod.fromJSON(pmDic))
				}
			}
		}
		
		promo.paymentMethods = paymentMethods
		
        promo.legals = json["legals"] == nil ? "" : json["legals"]?.stringValue
		
		return promo
	}
    
    public func toJSONString() -> String {
        var obj:[String:AnyObject] = [
            "promoId": self.promoId,
            "issuer" : self.issuer.toJSONString(),
            "recommendedMessage" : self.recommendedMessage,
            "legals" : self.legals,
            "url" : self.url
        ]
        
        var pmsJson = ""
        for pm in self.paymentMethods {
            pmsJson = pmsJson + pm.toJSONString()
        }
        obj["payment_methods"] = pmsJson

        return JSON(obj).toString()
    }
	
	public class func getDateFromString(string: String!) -> NSDate! {
		if string == nil {
			return nil
		}
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		var dateArr = string.characters.split {$0 == "T"}.map(String.init)
		return dateFormatter.dateFromString(dateArr[0])
	}
}


public func ==(obj1: Promo, obj2: Promo) -> Bool {
    let areEqual =
    obj1.promoId == obj2.promoId &&
    obj1.issuer == obj2.issuer &&
    obj1.recommendedMessage == obj2.recommendedMessage &&
    obj1.paymentMethods == obj2.paymentMethods &&
  //  obj1.legals == obj2.legals &&
    obj1.url == obj2.url
    
    return areEqual
}
