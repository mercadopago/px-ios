//
//  TransactionDetails.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

open class TransactionDetails: NSObject {
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
