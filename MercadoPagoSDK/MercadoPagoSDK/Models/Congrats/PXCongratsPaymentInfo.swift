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
    
    /// What the user should have paid, it has to include the currency.
    /// This amount represents the original price.
    let rawAmount: String?
    
    // Method
    /// A user friendly name for the payment method. For instance: `Visa` `Mastercad`
    let paymentMethodName: String?
    
    /// For credit cards, the last for digits of it.
    let paymentMethodLastFourDigits: String?
    
    /// A String representing the payment method icon
    let paymentMethodIconURL: String?
    
    let paymentMethodDescription: String?
    
    /// Type of payment method
    let paymentMethodType: PXPaymentTypes
    
    // Installments
    /// Interest rate applied to payment
    var installmentsRate: Double = 0
    
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
    
    /// Objc version
    @objc public convenience init(paidAmount: String, rawAmount: String?, paymentMethodName: String?, paymentMethodLastFourDigits: String? = nil, paymentMethodDescription: String?, paymentMethodIconURL: String?, paymentMethodType: PXPaymentOBJC, installmentsRate: Double, installmentsCount: Int, installmentsAmount: String?, installmentsTotalAmount: String?, discountName: String?) {
        self.init(paidAmount: paidAmount, rawAmount: rawAmount, paymentMethodName: paymentMethodName, paymentMethodLastFourDigits: paymentMethodLastFourDigits, paymentMethodDescription: paymentMethodDescription, paymentMethodIconURL: paymentMethodIconURL, paymentMethodType: paymentMethodType.getRealCase(), installmentsRate: installmentsRate, installmentsCount: installmentsCount, installmentsAmount: installmentsAmount, installmentsTotalAmount: installmentsTotalAmount, discountName: discountName)
    }
    
    /// Swift version
    @nonobjc public init(paidAmount: String, rawAmount: String?, paymentMethodName: String?, paymentMethodLastFourDigits: String? = nil, paymentMethodDescription: String?, paymentMethodIconURL: String?, paymentMethodType: PXPaymentTypes, installmentsRate: Double? = nil, installmentsCount: Int, installmentsAmount: String?, installmentsTotalAmount: String?, discountName: String?) {
        self.paidAmount = paidAmount
        self.rawAmount = rawAmount
        
        self.paymentMethodName = paymentMethodName
        if let lastFourDigits = paymentMethodLastFourDigits {
            self.paymentMethodLastFourDigits = String(lastFourDigits.prefix(4))
        } else {
            self.paymentMethodLastFourDigits = nil
        }
        self.paymentMethodDescription = paymentMethodDescription
        self.paymentMethodIconURL = paymentMethodIconURL
        self.paymentMethodType = paymentMethodType
        
        self.installmentsRate = installmentsRate ?? 0.0
        self.installmentsCount = installmentsCount
        self.installmentsAmount = installmentsAmount
        self.installmentsTotalAmount = installmentsTotalAmount
        
        self.discountName = discountName
        super.init()
    }
}

extension PXCongratsPaymentInfo {
    var hasInstallments: Bool {
        get {
            return installmentsCount > 0
        }
    }
    
    var hasDiscount: Bool {
        get {
            return discountName != nil
        }
    }
}
