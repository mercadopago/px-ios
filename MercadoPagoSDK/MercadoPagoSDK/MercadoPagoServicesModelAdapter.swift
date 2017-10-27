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
    
    open class func getInstructionsInfoFromPXInstructions(_ pxInstructions: PXInstructions) -> InstructionsInfo {
        let instructionsInfo = InstructionsInfo()
        return instructionsInfo
    }
    
    open class func getTokenFromPXToken(_ pxToken: PXToken) -> Token {
        let id: String = pxToken.id
        let publicKey: String = pxToken.publicKey
        let cardId: String = pxToken.cardId ?? ""
        let luhnValidation: String = pxToken.luhnValidation
        let status: String = pxToken.status
        let usedDate: String = getStringDateFromDate(pxToken.usedDate ?? Date())
        let cardNumberLength: Int = pxToken.cardNumberLength
        let creationDate: Date = pxToken.dateCreated ?? Date()
        let lastFourDigits: String = pxToken.lastFourDigits
        let firstSixDigits: String = pxToken.firstSixDigits
        let securityCodeLength: Int = pxToken.securityCodeLength
        let expirationMonth: Int = pxToken.expirationMonth
        let expirationYear: Int = pxToken.expirationYear
        let lastModifiedDate: Date = pxToken.dateLastUpdated ?? Date()
        let dueDate: Date = pxToken.dueDate ?? Date()
        let cardholder = getCardholderFromPXCardHolder(pxToken.cardholder)
        let token = Token(_id: id, publicKey: publicKey, cardId: cardId, luhnValidation: luhnValidation, status: status, usedDate: usedDate, cardNumberLength: cardNumberLength, creationDate: creationDate, lastFourDigits: lastFourDigits, firstSixDigit: firstSixDigits, securityCodeLength: securityCodeLength, expirationMonth: expirationMonth, expirationYear: expirationYear, lastModifiedDate: lastModifiedDate, dueDate: dueDate, cardHolder: cardholder)
        return token
    }
    
    open class func getStringDateFromDate(_ Date: Date) -> String {
        let stringDate = ""
        return stringDate
    }
    
    open class func getCardholderFromPXCardHolder(_ pxCardHolder: PXCardHolder) -> Cardholder {
        let cardholder = Cardholder()
        return cardholder
    }
    
    open class func getBankDealFromPXBankDeal(_ pxBankDeal: PXBankDeal) -> BankDeal {
        let bankDeal = BankDeal()
        bankDeal.promoId = pxBankDeal.id
        bankDeal.issuer = getIssuerFromPXIssuer(pxBankDeal.issuer)
        bankDeal.recommendedMessage = pxBankDeal.recommendedMessage
        for pxPaymentMethod in pxBankDeal.paymentMethods {
            let paymentMethod = getPaymentMethodFromPXPaymentMethod(pxPaymentMethod)
            bankDeal.paymentMethods.append(paymentMethod)
        }
        bankDeal.legals = pxBankDeal.legals
        bankDeal.url = pxBankDeal.picture.url
        return bankDeal
    }
    
    open class func getPaymentMethodFromPXPaymentMethod(_ pxPaymentMethod: PXPaymentMethod) -> PaymentMethod {
        let paymentMethod = PaymentMethod()
        paymentMethod.name = pxPaymentMethod.name
        paymentMethod.paymentTypeId = pxPaymentMethod.paymentTypeId
        if let pxSettings = pxPaymentMethod.settings {
            for pxSetting in pxSettings {
                let setting = getSettingFromPXSetting(pxSetting)
                paymentMethod.settings.append(setting)
            }
        } else {
            paymentMethod.settings = []
        }
        paymentMethod.additionalInfoNeeded = pxPaymentMethod.additionalInfoNeeded
        if let pxFinancialInstitutions = pxPaymentMethod.financialInstitutions {
            for pxFinancialInstitution in pxFinancialInstitutions {
                let financialInstitution = getFinancialInstitutionFromPXFinancialInstitution(pxFinancialInstitution)
                paymentMethod.financialInstitutions.append(financialInstitution)
            }
        } else {
            paymentMethod.financialInstitutions = []
        }
        paymentMethod.accreditationTime = pxPaymentMethod.accreditationTime
        paymentMethod.status = pxPaymentMethod.status
        paymentMethod.secureThumbnail = pxPaymentMethod.secureThumbnail
        paymentMethod.thumbnail = pxPaymentMethod.thumbnail
        paymentMethod.deferredCapture = pxPaymentMethod.deferredCapture
        paymentMethod.minAllowedAmount = pxPaymentMethod.minAllowedAmount!
        paymentMethod.maxAllowedAmount = pxPaymentMethod.maxAllowedAmount
        paymentMethod.merchantAccountId = pxPaymentMethod.merchantAccountId
        return paymentMethod
    }
    
    open class func getSettingFromPXSetting(_ pxSetting: PXSetting) -> Setting {
        let setting = Setting()
        setting.binMask = getBinMaskFromPXBin(pxSetting.bin)
        setting.cardNumber = getCardNumberFromPXCardNumber(pxSetting.cardNumber)
        setting.securityCode = getSecurityCodeFromPXSecurityCode(pxSetting.securityCode)
        return setting
    }
    
    open class func getFinancialInstitutionFromPXFinancialInstitution(_ pxFinancialInstitution: PXFinancialInstitution?) -> FinancialInstitution {
        if let pxFinancialInstitution = pxFinancialInstitution {
            let financialInstitution = FinancialInstitution()
            financialInstitution._id = Int(pxFinancialInstitution.id)
            financialInstitution._description = pxFinancialInstitution._description
            return financialInstitution
        } else {
            let financialInstitution = FinancialInstitution()
            return financialInstitution
        }
    }
    
    open class func getBinMaskFromPXBin(_ pxBin: PXBin?) -> BinMask {
        if let pxBin = pxBin {
            let binMask = BinMask()
            binMask.exclusionPattern = pxBin.exclusionPattern
            binMask.installmentsPattern = pxBin.installmentPattern
            binMask.pattern = pxBin.pattern
            return binMask
        } else {
            let binMask = BinMask()
            binMask.exclusionPattern = ""
            binMask.installmentsPattern = ""
            binMask.pattern = ""
            return binMask
        }
    }
    
    open class func getCardNumberFromPXCardNumber(_ pxCardNumber: PXCardNumber) -> CardNumber {
        let cardNumber = CardNumber()
        cardNumber.length = pxCardNumber.length
        cardNumber.validation = pxCardNumber.validation
        return cardNumber
    }
    
    open class func getSecurityCodeFromPXSecurityCode(_ pxSecurityCode: PXSecurityCode) -> SecurityCode {
        let securityCode = SecurityCode()
        securityCode.length = pxSecurityCode.length
        securityCode.cardLocation = pxSecurityCode.cardLocation
        securityCode.mode = pxSecurityCode.mode
        return securityCode
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
        let pxPayer = PXPayer(id: "String", accessToken: "String", identification: nil, type: nil, entityType: nil, email: nil, firstName: nil, lastName: nil)
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
        issuer._id = pxIssuer._id // TODO: Sacar el _
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
