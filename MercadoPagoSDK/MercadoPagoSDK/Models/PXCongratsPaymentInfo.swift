//
//  PXCongratsPaymentInfo.swift
//  MercadoPagoSDK
//
//  Created by Franco Risma on 05/08/2020.
//

import Foundation

@objcMembers
public class PXCongratsPaymentInfo: NSObject {
    // Payment
    /// What the user paid, it has to include the currency.
    let paidAmount: String
    /// What the should have paid, it has to include the currency.
    /// This amount represents the original price.
    let rawAmount: String?
    
    // Method
    let paymentMethodName: String
    let paymentMethodLastFourDigits: String?
    let paymentMethodExtraInfo: String?
    /// Used to show the issues logo. Defined at `PaymentMethodSearch`
    let paymentMethodId: String
    let paymentMethodType: PXPaymentTypes
    
    // Installments
    let hasInstallments: Bool
    let installmentsRate: Double?
    let installmentsCount: Int
    let installmentAmount: String?
    
    // Discount
    let hasDiscount: Bool
    // Some friendly message to be shown
    let discountName: String?
    
    public init(paidAmount: String, transactionAmount: String?, paymentMethodName: String, paymentMethodLastFourDigits: String?, paymentMethodExtraInfo: String?, paymentMethodId: String, paymentMethodType: PXPaymentTypes, hasInstallments: Bool = false, installmentsRate: Double? = nil, installmentsCount: Int = 0, installmentAmount: String? = nil, hasDiscount: Bool = false, discountName: String? = nil) {
        self.paidAmount = paidAmount
        self.rawAmount = transactionAmount
        
        self.paymentMethodName = paymentMethodName
        if let lastFourDigits = paymentMethodLastFourDigits {
            self.paymentMethodLastFourDigits = String(lastFourDigits.prefix(4))
        } else {
            self.paymentMethodLastFourDigits = nil
        }
        self.paymentMethodExtraInfo = paymentMethodExtraInfo
        self.paymentMethodId = paymentMethodId
        self.paymentMethodType = paymentMethodType
        
        self.hasInstallments = hasInstallments
        self.installmentsRate = installmentsRate
        self.installmentsCount = installmentsCount
        self.installmentAmount = installmentAmount
        
        self.hasDiscount = hasDiscount
        self.discountName = discountName
        super.init()
    }
}

