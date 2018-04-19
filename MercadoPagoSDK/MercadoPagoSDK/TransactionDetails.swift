//
//  TransactionDetails.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

@objcMembers open class TransactionDetails: NSObject {
    open var couponAmount: Double?
    open var externalResourceUrl: String?
    open var financialInstitution: FinancialInstitution?
    open var installmentAmount: Double?
    open var netReceivedAmount: Double?
    open var overpaidAmount: Double?
    open var totalPaidAmount: Double?

    override public init() {
        super.init()
    }

    open class func fromJSON(_ json: NSDictionary) -> TransactionDetails {
        let transactionDetails: TransactionDetails = TransactionDetails()
        if let couponAmount = JSONHandler.attemptParseToDouble(json["coupon_amount"]) {
            transactionDetails.couponAmount = couponAmount
        }
        if let externalResourceUrl = JSONHandler.attemptParseToString(json["external_resource_url"]) {
            transactionDetails.externalResourceUrl = externalResourceUrl
        }
        if let financialInstitution = json["financial_institution"] as? NSDictionary {
            transactionDetails.financialInstitution = FinancialInstitution.fromJSON(financialInstitution)
        }
        if let installmentAmount = JSONHandler.attemptParseToDouble(json["installment_amount"]) {
            transactionDetails.installmentAmount = installmentAmount
        }
        if let netReceivedAmount = JSONHandler.attemptParseToDouble(json["net_received_amount"]) {
            transactionDetails.netReceivedAmount = netReceivedAmount
        }
        if let overpaidAmount = JSONHandler.attemptParseToDouble(json["overpaid_amount"]) {
            transactionDetails.overpaidAmount = overpaidAmount
        }
        if let totalPaidAmount = JSONHandler.attemptParseToDouble(json["total_paid_amount"]) {
            transactionDetails.totalPaidAmount = totalPaidAmount
        }
        return transactionDetails
    }

    public init(financialInstitution: FinancialInstitution? = nil) {
        self.financialInstitution = financialInstitution
    }

    open func toJSON() -> [String: Any] {

        var obj: [String: Any] = [:]

        if self.couponAmount != nil {
            obj["coupon_amount"] = self.couponAmount
        }
        if self.externalResourceUrl != nil {
            obj["external_resource_url"] = self.externalResourceUrl
        }
        if self.financialInstitution != nil, let ID = self.financialInstitution?.financialInstitutionId {
            if String(describing: ID).count >= 1 {
                obj["financial_institution"] = String(describing: ID)
            }

        }
        if self.installmentAmount != nil {
            obj["installment_amount"] = self.installmentAmount
        }
        if self.netReceivedAmount != nil {
            obj["net_received_amount"] = self.netReceivedAmount
        }
        if self.overpaidAmount != nil {
            obj["overpaid_amount"] = self.overpaidAmount
        }
        if self.totalPaidAmount != nil {
            obj["total_paid_amount"] = self.totalPaidAmount
        }

        return obj
    }

}
