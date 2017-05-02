//
//  TransactionDetails.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

open class TransactionDetails : NSObject {
    open var couponAmount : Double = 0
    open var externalResourceUrl : String!
    open var financialInstitution : String!
    open var installmentAmount : Double = 0
    open var netReceivedAmount : Double = 0
    open var overpaidAmount : Double = 0
    open var totalPaidAmount : Double = 0
    
    override public init(){
        super.init()
    }
    
    
    open class func fromJSON(_ json : NSDictionary) -> TransactionDetails {
        let transactionDetails : TransactionDetails = TransactionDetails()
        if let couponAmount = JSONHandler.attemptParseToDouble(json["coupon_amount"]){
            transactionDetails.couponAmount = couponAmount
        }
        if let externalResourceUrl = JSONHandler.attemptParseToString(json["external_resource_url"]){
            transactionDetails.externalResourceUrl = externalResourceUrl
        }
        if let financialInstitution = JSONHandler.attemptParseToString(json["financial_institution"]){
            transactionDetails.financialInstitution = financialInstitution
        }
        if let installmentAmount = JSONHandler.attemptParseToDouble(json["installment_amount"]){
            transactionDetails.installmentAmount = installmentAmount
        }
        if let netReceivedAmount = JSONHandler.attemptParseToDouble(json["net_received_amount"]){
            transactionDetails.netReceivedAmount = netReceivedAmount
        }
        if let overpaidAmount = JSONHandler.attemptParseToDouble(json["overpaid_amount"]){
            transactionDetails.overpaidAmount = overpaidAmount
        }
        if let totalPaidAmount = JSONHandler.attemptParseToDouble(json["total_paid_amount"]){
            transactionDetails.totalPaidAmount = totalPaidAmount
        }
        return transactionDetails
    }
}



public func ==(obj1: TransactionDetails, obj2: TransactionDetails) -> Bool {
    let areEqual =
    obj1.couponAmount == obj2.couponAmount &&
    obj1.couponAmount == obj2.couponAmount &&
    obj1.externalResourceUrl == obj2.externalResourceUrl &&
    obj1.financialInstitution == obj2.financialInstitution &&
    obj1.installmentAmount == obj2.installmentAmount &&
    obj1.netReceivedAmount == obj2.netReceivedAmount &&
    obj1.overpaidAmount == obj2.overpaidAmount &&
    obj1.totalPaidAmount == obj2.totalPaidAmount
    
    return areEqual
}




