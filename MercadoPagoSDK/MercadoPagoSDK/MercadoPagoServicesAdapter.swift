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
    
    open class func getPaymentMethodSearch(amount: Double, excludedPaymentTypesIds: Set<String>?, excludedPaymentMethodsIds: Set<String>?, payer: Payer, site: String, callback : @escaping (PaymentMethodSearch) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        let pxPayer = getPXPayerByPayer(payer)
        let pxSite = getPXSiteById(site)
        
        MercadoPagoServices.getPaymentMethodSearch(amount: amount, excludedPaymentTypesIds: excludedPaymentTypesIds, excludedPaymentMethodsIds: excludedPaymentMethodsIds, payer: pxPayer, site: pxSite, callback: { (pxPaymentMethodSearch) in
            let paymentMethodSearch = getPaymentMethodSearchByPXPaymentMethodSearch(pxPaymentMethodSearch)
            callback(paymentMethodSearch)
        }, failure: failure)
    }
    
    open class func getPXSiteById(_ siteId: String) -> PXSite {
        let pxSite = PXSite()
        return pxSite
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
