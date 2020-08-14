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
    /// A user friendly name for the payment method. For instance: `Visa` `Mastercad`
    let paymentMethodName: String
    
    /// For credit cards, the last for digits of it.
    let paymentMethodLastFourDigits: String?
    
    
    let paymentMethodDescription: String?
    
    /// Used to show the issues logo. Defined at `PaymentMethodSearch`
    let paymentMethodId: String
    
    /// Type of payment method
    let paymentMethodType: PXPaymentTypes
    
    // Installments
    /// Interest rate applied to payment
    let installmentsRate: Double?
    
    /// Number of installments
    let installmentsCount: Int
    
    /// Cost of each installment. Must be formatted with a curreny
    let installmentsAmount: String?
    
    /// Total cost of payment with installments. Must be formatted with a curreny.
    /// When setting `installmentsCount` bigger than 1, `paidAmount` is
    /// ignored and `installmentsTotalAmount` is used.
    let installmentsTotalAmount: String?
    
    // Discount
    /// Some friendly message to be shown when a discount is applied
    let discountName: String?
    
    public init(paidAmount: String, rawAmount: String?, paymentMethodName: String, paymentMethodLastFourDigits: String? = nil, paymentMethodDescription: String? = nil, paymentMethodId: String, paymentMethodType: PXPaymentTypes, installmentsRate: Double? = nil, installmentsCount: Int = 0, installmentsAmount: String? = nil, installmentsTotalAmount: String? = nil, discountName: String? = nil) {
        self.paidAmount = paidAmount
        self.rawAmount = rawAmount
        
        self.paymentMethodName = paymentMethodName
        if let lastFourDigits = paymentMethodLastFourDigits {
            self.paymentMethodLastFourDigits = String(lastFourDigits.prefix(4))
        } else {
            self.paymentMethodLastFourDigits = nil
        }
        self.paymentMethodDescription = paymentMethodDescription
        self.paymentMethodId = paymentMethodId
        self.paymentMethodType = paymentMethodType
        
        self.installmentsRate = installmentsRate
        self.installmentsCount = installmentsCount
        self.installmentsAmount = installmentsAmount
        self.installmentsTotalAmount = installmentsTotalAmount
        
        self.discountName = discountName
        super.init()
    }
}

