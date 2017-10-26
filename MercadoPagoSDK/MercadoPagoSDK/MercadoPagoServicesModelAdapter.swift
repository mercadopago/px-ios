//
//  MercadoPagoServicesModelAdapter.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 10/25/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoServices

extension MercadoPagoServicesAdapter {
    
    open class func getPXSiteFromId(_ siteId: String) -> PXSite {
        let currency = MercadoPagoContext.getCurrency()
        let pxCurrency = getPXCurrencyFromCurrency(currency)
        let pxSite = PXSite(id: siteId, currencyId: pxCurrency.id)
        return pxSite
    }
    
    open class func getPXCurrencyFromCurrency(_ currency: Currency) -> PXCurrency {
        let id: String = currency._id
        let description: String = currency._description
        let symbol: String = currency.symbol
        let decimalPlaces: Int = currency.decimalPlaces
        let decimalSeparator: String = currency.decimalSeparator
        let thousandSeparator: String = currency.thousandsSeparator
        let pxCurrency = PXCurrency(id: id, description: description, symbol: symbol, decimalPlaces: decimalPlaces, decimalSeparator: decimalSeparator, thousandSeparator: thousandSeparator)
        return pxCurrency
    }
    
    open class func getCheckoutPreferenceFromPXCheckoutPreference(_ pxCheckoutPreference: PXCheckoutPreference) -> CheckoutPreference {
        let checkoutPreference = CheckoutPreference()
        return checkoutPreference
    }
    
    open class func getDiscountCouponFromPXDiscount(_ pxDiscount: PXDiscount) -> DiscountCoupon {
        let discountCoupon = DiscountCoupon()
        return discountCoupon
    }
    
    open class func getPaymentFromPXPayment(_ pxPayment: PXPayment) -> Payment {
        let payment = Payment()
        return payment
    }
    
    open class func getPXPayerFromPayer(_ payer: Payer) -> PXPayer {
        let pxPayer = PXPayer()
        return pxPayer
    }
    
    open class func getPayerFromPXPayer(_ pxPayer: PXPayer) -> Payer {
        let payer = Payer()
        return payer
    }
    
    open class func getPaymentMethodSearchFromPXPaymentMethodSearch(_ pxPaymentMethodSearch: PXPaymentMethodSearch) -> PaymentMethodSearch {
        let paymentMethodSearch = PaymentMethodSearch()
        return paymentMethodSearch
    }
    
    open class func getCustomerFromPXCustomer(_ pxCustomer: PXCustomer) -> Customer {
        let customer = Customer()
        return customer
    }
    
    open class func getIssuerFromPXIssuer(_ pxIssuer: PXIssuer) -> Issuer {
        let issuer = Issuer()
        issuer._id = pxIssuer.id
        issuer.name = pxIssuer.name
        return issuer
    }
    
    open class func getInstallmentFromPXInstallment(_ pxInstallment: PXInstallment) -> Installment {
        let installment = Installment()
        installment.issuer = getIssuerFromPXIssuer(pxInstallment.issuer)
        installment.paymentTypeId = pxInstallment.paymentTypeId
        installment.paymentMethodId = pxInstallment.paymentMethodId
        for pxPayerCost in pxInstallment.payerCosts {
            let payerCost = getPayerCostFromPXPayerCost(pxPayerCost)
            installment.payerCosts.append(payerCost)
        }
        return installment
    }
    
    open class func getPayerCostFromPXPayerCost(_ pxPayerCost: PXPayerCost) -> PayerCost {
        let payerCost = PayerCost()
        payerCost.installmentRate = pxPayerCost.installmentRate
        payerCost.labels = pxPayerCost.labels
        payerCost.minAllowedAmount = pxPayerCost.minAllowedAmount
        payerCost.maxAllowedAmount = pxPayerCost.maxAllowedAmount
        payerCost.recommendedMessage = pxPayerCost.recommendedMessage
        payerCost.installmentAmount = pxPayerCost.installmentAmount
        payerCost.totalAmount = pxPayerCost.totalAmount
        return payerCost
    }
}
