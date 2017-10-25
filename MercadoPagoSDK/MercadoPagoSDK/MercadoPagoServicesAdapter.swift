//
//  MercadoPagoServicesAdapter.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 10/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoServices

open class MercadoPagoServicesAdapter: NSObject {
    
    open class func getCodeDiscount(amount: Double, payerEmail: String, couponCode: String?, discountAdditionalInfo: NSDictionary?, callback: @escaping (DiscountCoupon?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        MercadoPagoServices.getCodeDiscount(amount: amount, payerEmail: payerEmail, couponCode: couponCode, discountAdditionalInfo: discountAdditionalInfo, callback: { (pxDiscount) in
            if let pxDiscount = pxDiscount {
                let discountCoupon = getDiscountCouponByPXDiscount(pxDiscount)
                callback(discountCoupon)
            } else {
                callback(nil)
            }
        }, failure: failure)
    }
    
    open class func getDirectDiscount(amount: Double, payerEmail: String, discountAdditionalInfo: NSDictionary?, callback: @escaping (DiscountCoupon?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        getCodeDiscount(amount: amount, payerEmail: payerEmail, couponCode: nil, discountAdditionalInfo: discountAdditionalInfo, callback: callback, failure: failure)
    }

    open class func getInstallments(bin: String?, amount: Double, issuer: Issuer?, paymentMethodId: String, callback: @escaping ([Installment]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        MercadoPagoServices.getInstallments(bin: bin, amount: amount, issuerId: issuer?._id, paymentMethodId: paymentMethodId, callback: { (pxInstallments) in
            var installments: [Installment] = []
            for pxInstallment in pxInstallments {
                let installment = getInstallmentByPXInstallment(pxInstallment)
                installments.append(installment)
            }
            callback(installments)
        }, failure: failure)
    }
    
    open class func getIssuers(paymentMethodId: String, bin: String? = nil, callback: @escaping ([Issuer]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        MercadoPagoServices.getIssuers(paymentMethodId: paymentMethodId, bin: bin, callback: { (pxIssuers) in
            var issuers: [Issuer] = []
            for pxIssuer in pxIssuers {
                let issuer = getIssuerByPXIssuer(pxIssuer)
                issuers.append(issuer)
            }
            callback(issuers)
        }, failure: failure)
    }
    
    open class func getCustomer(additionalInfo: NSDictionary? = nil, callback: @escaping (Customer) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        MercadoPagoServices.getCustomer(additionalInfo: additionalInfo, callback: { (pxCustomer) in
            let customer = getCustomerByPXCustomer(pxCustomer)
            callback(customer)
        }, failure: failure)
    }
    
    open class func getPaymentMethodSearch(amount: Double, excludedPaymentTypesIds: Set<String>?, excludedPaymentMethodsIds: Set<String>?, defaultPaymentMethod: String?, payer: Payer, site: String, callback : @escaping (PaymentMethodSearch) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        let pxPayer = getPXPayerByPayer(payer)
        let pxSite = getPXSiteById(site)
        
        MercadoPagoServices.getPaymentMethodSearch(amount: amount, excludedPaymentTypesIds: excludedPaymentTypesIds, excludedPaymentMethodsIds: excludedPaymentMethodsIds, defaultPaymentMethod: defaultPaymentMethod, payer: pxPayer, site: pxSite, callback: { (pxPaymentMethodSearch) in
            let paymentMethodSearch = getPaymentMethodSearchByPXPaymentMethodSearch(pxPaymentMethodSearch)
            callback(paymentMethodSearch)
        }, failure: failure)
    }
    
    open class func getPXSiteById(_ siteId: String) -> PXSite {
        let currency = MercadoPagoContext.getCurrency()
        let pxCurrency = getPXCurrencyByCurrency(currency)
        let pxSite = PXSite(id: siteId, currencyId: pxCurrency.id)
        return pxSite
    }
    
    open class func getPXCurrencyByCurrency(_ currency: Currency) -> PXCurrency {
        let id: String = currency._id
        let description: String = currency._description
        let symbol: String = currency.symbol
        let decimalPlaces: Int = currency.decimalPlaces
        let decimalSeparator: String = currency.decimalSeparator
        let thousandSeparator: String = currency.thousandsSeparator
        let pxCurrency = PXCurrency(id: id, description: description, symbol: symbol, decimalPlaces: decimalPlaces, decimalSeparator: decimalSeparator, thousandSeparator: thousandSeparator)
        return pxCurrency
    }
    
    open class func getDiscountCouponByPXDiscount(_ pxDiscount: PXDiscount) -> DiscountCoupon {
        let discountCoupon = DiscountCoupon()
        return discountCoupon
    }
    
    open class func getPXPayerByPayer(_ payer: Payer) -> PXPayer {
        let pxPayer = PXPayer()
        return pxPayer
    }
    
    open class func getPayerByPXPayer(_ pxPayer: PXPayer) -> Payer {
        let payer = Payer()
        return payer
    }
    
    open class func getPaymentMethodSearchByPXPaymentMethodSearch(_ pxPaymentMethodSearch: PXPaymentMethodSearch) -> PaymentMethodSearch {
        let paymentMethodSearch = PaymentMethodSearch()
        return paymentMethodSearch
    }
    
    open class func getCustomerByPXCustomer(_ pxCustomer: PXCustomer) -> Customer {
        let customer = Customer()
        return customer
    }
    
    open class func getIssuerByPXIssuer(_ pxIssuer: PXIssuer) -> Issuer {
        let issuer = Issuer()
        issuer._id = pxIssuer.id
        issuer.name = pxIssuer.name
        return issuer
    }
    
    open class func getInstallmentByPXInstallment(_ pxInstallment: PXInstallment) -> Installment {
        let installment = Installment()
        installment.issuer = getIssuerByPXIssuer(pxInstallment.issuer)
        installment.paymentTypeId = pxInstallment.paymentTypeId
        installment.paymentMethodId = pxInstallment.paymentMethodId
        for pxPayerCost in pxInstallment.payerCosts {
            let payerCost = getPayerCostByPXPayerCost(pxPayerCost)
            installment.payerCosts.append(payerCost)
        }
        return installment
    }
    
    open class func getPayerCostByPXPayerCost(_ pxPayerCost: PXPayerCost) -> PayerCost {
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
