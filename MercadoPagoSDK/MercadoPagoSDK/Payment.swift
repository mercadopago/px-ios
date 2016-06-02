//
//  Payment.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

public class Payment : NSObject {
    public var binaryMode : Bool!
    public var callForAuthorizeId : String!
    public var captured : Bool!
    public var card : Card!
    public var currencyId : String!
    public var dateApproved : NSDate!
    public var dateCreated : NSDate!
    public var dateLastUpdated : NSDate!
    public var _description : String!
    public var externalReference : String!
    public var feesDetails : [FeesDetail]!
    public var _id : Int = 0
    public var installments : Int = 0
    public var liveMode : Bool!
    public var metadata : NSObject!
    public var moneyReleaseDate : NSDate!
    public var notificationUrl : String!
    public var order : Order!
    public var payer : Payer!
    public var paymentMethodId : String!
    public var paymentTypeId : String!
    public var refunds : [Refund]!
    public var statementDescriptor : String!
    public var status : String!
    public var statusDetail : String!
    public var transactionAmount : Double = 0
    public var transactionAmountRefunded : Double = 0
    public var transactionDetails : TransactionDetails!
    public var collectorId : String!
    public var couponAmount : Double = 0
    public var differentialPricingId : NSNumber = 0
    public var issuerId : Int = 0
    public var tokenId : String?
    
    override public init(){
        super.init()
    }
    
    public class func fromJSON(json : NSDictionary) -> Payment {
        let payment : Payment = Payment()
		
		if json["id"] != nil && !(json["id"]! is NSNull) {
			payment._id = (json["id"]! as? Int)!
		}
		
        if json["binary_mode"] != nil && !(json["binary_mode"]! is NSNull) {
            payment.binaryMode = JSON(json["binary_mode"]!).asBool
        }
        if json["captured"] != nil && !(json["captured"]! is NSNull) {
            payment.captured = JSON(json["captured"]!).asBool
        }
		
		if json["currency_id"] != nil && !(json["currency_id"]! is NSNull) {
			payment.currencyId = JSON(json["currency_id"]!).asString
		}
		
		if json["money_release_date"] != nil && !(json["money_release_date"]! is NSNull) {
			payment.moneyReleaseDate = getDateFromString(json["money_release_date"] as? String)
		}
		if json["date_created"] != nil && !(json["date_created"]! is NSNull) {
			payment.dateCreated = getDateFromString(json["date_created"] as? String)
		}
		if json["date_last_updated"] != nil && !(json["date_last_updated"]! is NSNull) {
			payment.dateLastUpdated = getDateFromString(json["date_last_updated"] as? String)
		}
		if json["date_approved"] != nil && !(json["date_approved"]! is NSNull) {
			payment.dateApproved = getDateFromString(json["date_approved"] as? String)
		}
		if json["description"] != nil && !(json["description"]! is NSNull) {
			payment._description = JSON(json["description"]!).asString
		}
		if json["external_reference"] != nil && !(json["external_reference"]! is NSNull) {
			payment.externalReference = JSON(json["external_reference"]!).asString
		}
		if json["installments"] != nil && !(json["installments"]! is NSNull) {
			payment.installments = (json["installments"] as? Int	)!
		}
		if json["live_mode"] != nil && !(json["live_mode"]! is NSNull) {
			payment.liveMode = JSON(json["live_mode"]!).asBool
		}
		if json["notification_url"] != nil && !(json["notification_url"]! is NSNull) {
			payment.notificationUrl = JSON(json["notification_url"]!).asString
		}
        var feesDetails : [FeesDetail] = [FeesDetail]()
        if let feesDetailsArray = json["fee_details"] as? NSArray {
            for i in 0..<feesDetailsArray.count {
                if let feedDic = feesDetailsArray[i] as? NSDictionary {
                    feesDetails.append(FeesDetail.fromJSON(feedDic))
                }
            }
        }
        payment.feesDetails = feesDetails
        let cardDic = json["card"] as? NSDictionary
        if cardDic != nil && cardDic?.count > 0 {
            payment.card = Card.fromJSON(cardDic!)
        }
        if let orderDic = json["order"] as? NSDictionary {
            payment.order = Order.fromJSON(orderDic)
        }
        if let payerDic = json["payer"] as? NSDictionary {
            payment.payer = Payer.fromJSON(payerDic)
        }
		if json["payment_method_id"] != nil && !(json["payment_method_id"]! is NSNull) {
			payment.paymentMethodId = JSON(json["payment_method_id"]!).asString
		}
		if json["payment_type_id"] != nil && !(json["payment_type_id"]! is NSNull) {
			payment.paymentTypeId = JSON(json["payment_type_id"]!).asString
		}
        var refunds : [Refund] = [Refund]()
        if let refArray = json["refunds"] as? NSArray {
            for i in 0..<refArray.count {
                if let refDic = refArray[i] as? NSDictionary {
                    refunds.append(Refund.fromJSON(refDic))
                }
            }
        }
        payment.refunds = refunds
		if json["statement_descriptor"] != nil && !(json["statement_descriptor"]! is NSNull) {
			payment.statementDescriptor = JSON(json["statement_descriptor"]!).asString
		}
		if json["status"] != nil && !(json["status"]! is NSNull) {
			payment.status = JSON(json["status"]!).asString
		}
		if json["status_detail"] != nil && !(json["status_detail"]! is NSNull) {
			payment.statusDetail = JSON(json["status_detail"]!).asString
		}
		if json["transaction_amount"] != nil && !(json["transaction_amount"]! is NSNull) {
			payment.transactionAmount = JSON(json["transaction_amount"]!).asDouble!
		}
		if json["transaction_amount_refunded"] != nil && !(json["transaction_amount_refunded"]! is NSNull) {
			payment.transactionAmountRefunded = JSON(json["transaction_amount_refunded"]!).asDouble!
		}
        if let tdDic = json["transaction_details"] as? NSDictionary {
            payment.transactionDetails = TransactionDetails.fromJSON(tdDic)
        }
        payment.collectorId = json["collector_id"] as? String
		if json["coupon_amount"] != nil && !(json["coupon_amount"]! is NSNull) {
			payment.couponAmount = JSON(json["coupon_amount"]!).asDouble!
		}
		if json["differential_pricing_id"] != nil && !(json["differential_pricing_id"]! is NSNull) {
			payment.differentialPricingId = NSNumber(longLong: (json["differential_pricing_id"]!.longLongValue))
		}
		
		if json["issuer_id"] != nil && !(json["issuer_id"]! is NSNull) {
			payment.issuerId = (json["issuer_id"] as? NSString)!.integerValue
		}
        
        if json["token"] != nil && !(json["token"]! is NSNull) {
            payment.tokenId = (json["token"] as? String)! 
        }
        return payment
    }
    
    public func toJSONString() -> String {
        let obj:[String:AnyObject] = [
            "transaction_amount": self.transactionAmount,
            "token": self.tokenId == nil ? "" : self.tokenId!,
            "description": self._description,
            //TODO : should be plural
            //            "items": JSON(self.items[0]),
            "installments" : self.installments == 0 ? 0 : self.installments,
            "payment_method_id" : self.paymentMethodId
        ]
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
    
    public func isRejected() -> Bool {
        return self.status == PaymentStatus.REJECTED.rawValue
    }
}




public func ==(obj1: Payment, obj2: Payment) -> Bool {
    
    let areEqual =
    obj1.tokenId == obj2.tokenId &&
    //obj1.binaryMode == obj2.binaryMode &&
    obj1.issuerId == obj2.issuerId &&
    obj1.differentialPricingId == obj2.differentialPricingId &&
    obj1.couponAmount == obj2.couponAmount &&
    obj1.collectorId == obj2.collectorId &&
    obj1.transactionDetails == obj2.transactionDetails &&
    obj1.transactionAmountRefunded == obj2.transactionAmountRefunded &&
    obj1.transactionAmount == obj2.transactionAmount &&
    obj1.statusDetail == obj2.statusDetail &&
    obj1.status == obj2.status &&
    obj1.statementDescriptor == obj2.statementDescriptor &&
    obj1.refunds == obj2.refunds &&
    obj1.paymentTypeId == obj2.paymentTypeId &&
    obj1.paymentMethodId == obj2.paymentMethodId &&
    obj1.payer == obj2.payer &&
    obj1.order == obj2.order &&
    obj1.notificationUrl == obj2.notificationUrl &&
  //  obj1.moneyReleaseDate == obj2.moneyReleaseDate &&
   // obj1.metadata == obj2.metadata &&
  //  obj1.liveMode == obj2.liveMode &&
    obj1.installments == obj2.installments &&
    obj1._id == obj2._id &&
    obj1.feesDetails == obj2.feesDetails &&
    obj1.externalReference == obj2.externalReference &&
    obj1._description == obj2._description &&
   // obj1.dateLastUpdated == obj2.dateLastUpdated &&
    //obj1.dateCreated == obj2.dateCreated &&
  //  obj1.dateApproved == obj2.dateApproved &&
    obj1.currencyId == obj2.currencyId &&
    obj1.card == obj2.card //&&
    //obj1.captured == obj2.captured &&
   // obj1.callForAuthorizeId == obj2.callForAuthorizeId
    
    return areEqual
}