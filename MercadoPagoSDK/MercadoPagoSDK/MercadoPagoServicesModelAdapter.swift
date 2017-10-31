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

    open func getPXSiteFromId(_ siteId: String) -> PXSite {
        let currency = MercadoPagoContext.getCurrency()
        let pxCurrency = getPXCurrencyFromCurrency(currency)
        let pxSite = PXSite(id: siteId, currencyId: pxCurrency.id)
        return pxSite
    }

    open func getPXCurrencyFromCurrency(_ currency: Currency) -> PXCurrency {
        let id: String = currency._id
        let description: String = currency._description
        let symbol: String = currency.symbol
        let decimalPlaces: Int = currency.decimalPlaces
        let decimalSeparator: String = currency.decimalSeparator
        let thousandSeparator: String = currency.thousandsSeparator
        let pxCurrency = PXCurrency(id: id, description: description, symbol: symbol, decimalPlaces: decimalPlaces, decimalSeparator: decimalSeparator, thousandSeparator: thousandSeparator)
        return pxCurrency
    }
    
    open func getCurrencyFromPXCurrency(_ pxCurrency: PXCurrency) -> Currency {
        let _id: String = pxCurrency.id
        let description: String = pxCurrency._description
        let symbol: String = pxCurrency.symbol
        let decimalPlaces: Int = pxCurrency.decimalPlaces
        let decimalSeparator: String = pxCurrency.decimalSeparator
        let thousandSeparator: String = pxCurrency.thousandSeparator
        let currency = Currency(_id: _id, description: description, symbol: symbol, decimalPlaces: decimalPlaces, decimalSeparator: decimalSeparator, thousandSeparator: thousandSeparator)
        return currency
    }

    open func getCheckoutPreferenceFromPXCheckoutPreference(_ pxCheckoutPreference: PXCheckoutPreference) -> CheckoutPreference {
        let checkoutPreference = CheckoutPreference()
        checkoutPreference._id = pxCheckoutPreference.id
        for pxItem in pxCheckoutPreference.items {
            let item = getItemFromPXItem(pxItem)
            checkoutPreference.items = Array.safeAppend(checkoutPreference.items, item)
        }
        checkoutPreference.payer = getPayerFromPXPayer(pxCheckoutPreference.payer)
        checkoutPreference.paymentPreference = getPaymentPreferenceFromPXPaymentPreference(pxCheckoutPreference.paymentPreference)
        checkoutPreference.siteId = pxCheckoutPreference.siteId
        checkoutPreference.expirationDateFrom = pxCheckoutPreference.expirationDateFrom
        checkoutPreference.expirationDateTo = pxCheckoutPreference.expirationDateTo
        return checkoutPreference
    }

    open func getItemFromPXItem(_ pxItem: PXItem) -> Item {
        let id: String = pxItem.id
        let title: String = pxItem.title
        let quantity: Int = pxItem.quantity
        let unitPrice: Double = pxItem.unitPrice
        let description: String = pxItem._description
        let currencyId: String = pxItem.currencyId
        let item = Item(_id: id, title: title, quantity: quantity, unitPrice: unitPrice, description: description, currencyId: currencyId)
        return item
    }

    open func getPaymentPreferenceFromPXPaymentPreference(_ pxPaymentPreference: PXPaymentPreference) -> PaymentPreference {
        let paymentPreference = PaymentPreference()
        paymentPreference.excludedPaymentMethodIds = Set(pxPaymentPreference.excludedPaymentMethodIds)
        paymentPreference.excludedPaymentTypeIds = Set(pxPaymentPreference.excludedPaymentTypeIds)
        paymentPreference.defaultPaymentMethodId = pxPaymentPreference.defaultPaymentMethodId
        paymentPreference.maxAcceptedInstallments = pxPaymentPreference.maxAcceptedInstallments != nil ? pxPaymentPreference.maxAcceptedInstallments! : paymentPreference.maxAcceptedInstallments
        paymentPreference.defaultInstallments = pxPaymentPreference.defaultInstallments != nil ? pxPaymentPreference.defaultInstallments! : paymentPreference.defaultInstallments
        paymentPreference.defaultPaymentTypeId = pxPaymentPreference.defaultPaymentTypeId
        return paymentPreference
    }

    open func getInstructionsInfoFromPXInstructions(_ pxInstructions: PXInstructions) -> InstructionsInfo {
        let instructionsInfo = InstructionsInfo()
        instructionsInfo.amountInfo = getAmountInfoFromPXAmountInfo(pxInstructions.amountInfo)
        
        for pxInstruction in pxInstructions.instructions {
            let instruction = getInstructionFromPXInstruction(pxInstruction)
            instructionsInfo.instructions = Array.safeAppend(instructionsInfo.instructions, instruction)
        }
        
        return instructionsInfo
    }
    
    open func getInstructionFromPXInstruction(_ pxInstruction: PXInstruction) -> Instruction {
        let instruction = Instruction()
        instruction.title = pxInstruction.title
        instruction.subtitle = pxInstruction.subtitle
        instruction.accreditationMessage = pxInstruction.accreditationMessage
        instruction.accreditationComment = pxInstruction.accreditationComments
        
        for pxInstructionReference in pxInstruction.references {
            let instructionReference = getInstructionReferenceFromPXInstructionReference(pxInstructionReference)
            instruction.references = Array.safeAppend(instruction.references, instructionReference)
        }
        
        instruction.info = pxInstruction.info
        instruction.secondaryInfo = pxInstruction.secondaryInfo
        instruction.tertiaryInfo = pxInstruction.tertiaryInfo

        for pxInstructionAction in pxInstruction.action {
            let instructionAction = getInstructionActionFromPXInstructionAction(pxInstructionAction)
            instruction.actions = Array.safeAppend(instruction.actions, instructionAction)
        }
        
        instruction.type = pxInstruction.type
        return instruction
    }
    
    open func getInstructionReferenceFromPXInstructionReference(_ pxInstructionReference: PXInstructionReference) -> InstructionReference {
        let instructionReference = InstructionReference()
        instructionReference.label = pxInstructionReference.label
        instructionReference.value = pxInstructionReference.fieldValue
        instructionReference.separator = pxInstructionReference.separator
        instructionReference.comment = pxInstructionReference.comment
        return instructionReference
    }
    
    open func getInstructionActionFromPXInstructionAction(_ pxInstructionAction: PXInstructionAction) -> InstructionAction {
        let instructionAction = InstructionAction()
        instructionAction.label = pxInstructionAction.label
        instructionAction.url = pxInstructionAction.url
        instructionAction.tag = pxInstructionAction.tag
        return instructionAction
    }
    
    open func getAmountInfoFromPXAmountInfo(_ pxAmountInfo: PXAmountInfo) -> AmountInfo {
        let amountInfo = AmountInfo()
        amountInfo.amount = pxAmountInfo.amount
        amountInfo.currency = getCurrencyFromPXCurrency(pxAmountInfo.currency)
        return amountInfo
    }

    open func getTokenFromPXToken(_ pxToken: PXToken) -> Token {
        let id: String = pxToken.id
        let publicKey: String = pxToken.publicKey
        let cardId: String = pxToken.cardId ?? ""
        let luhnValidation: String = pxToken.luhnValidation.description
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

    open func getStringDateFromDate(_ date: Date) -> String {
        let stringDate = String(describing: date)
        return stringDate
    }

    open func getCardholderFromPXCardHolder(_ pxCardHolder: PXCardHolder) -> Cardholder {
        let cardholder = Cardholder()
        cardholder.name = pxCardHolder.name
        cardholder.identification = getIdentificationFromPXIdentification(pxCardHolder.identification)
        return cardholder
    }

    open func getBankDealFromPXBankDeal(_ pxBankDeal: PXBankDeal) -> BankDeal {
        let bankDeal = BankDeal()
        bankDeal.promoId = pxBankDeal.id
        bankDeal.issuer = getIssuerFromPXIssuer(pxBankDeal.issuer)
        bankDeal.recommendedMessage = pxBankDeal.recommendedMessage
        for pxPaymentMethod in pxBankDeal.paymentMethods {
            let paymentMethod = getPaymentMethodFromPXPaymentMethod(pxPaymentMethod)
            bankDeal.paymentMethods = Array.safeAppend(bankDeal.paymentMethods, paymentMethod)
        }
        bankDeal.legals = pxBankDeal.legals
        bankDeal.url = pxBankDeal.picture.url
        return bankDeal
    }

    open func getPaymentMethodFromPXPaymentMethod(_ pxPaymentMethod: PXPaymentMethod) -> PaymentMethod {
        let paymentMethod = PaymentMethod()
        paymentMethod._id = pxPaymentMethod.id
        paymentMethod.name = pxPaymentMethod.name
        paymentMethod.paymentTypeId = pxPaymentMethod.paymentTypeId
        if let pxSettings = pxPaymentMethod.settings {
            for pxSetting in pxSettings {
                let setting = getSettingFromPXSetting(pxSetting)
                paymentMethod.settings = Array.safeAppend(paymentMethod.settings, setting)
            }
        } else {
            paymentMethod.settings = []
        }
        paymentMethod.additionalInfoNeeded = pxPaymentMethod.additionalInfoNeeded
        if let pxFinancialInstitutions = pxPaymentMethod.financialInstitutions {
            for pxFinancialInstitution in pxFinancialInstitutions {
                let financialInstitution = getFinancialInstitutionFromPXFinancialInstitution(pxFinancialInstitution)
                paymentMethod.financialInstitutions = Array.safeAppend(paymentMethod.financialInstitutions, financialInstitution)
            }
        } else {
            paymentMethod.financialInstitutions = []
        }
        paymentMethod.accreditationTime = pxPaymentMethod.accreditationTime
        paymentMethod.status = pxPaymentMethod.status
        paymentMethod.secureThumbnail = pxPaymentMethod.secureThumbnail
        paymentMethod.thumbnail = pxPaymentMethod.thumbnail
        paymentMethod.deferredCapture = pxPaymentMethod.deferredCapture
        paymentMethod.minAllowedAmount = pxPaymentMethod.minAllowedAmount ?? 0
        paymentMethod.maxAllowedAmount = pxPaymentMethod.maxAllowedAmount
        paymentMethod.merchantAccountId = pxPaymentMethod.merchantAccountId
        return paymentMethod
    }

    open func getSettingFromPXSetting(_ pxSetting: PXSetting) -> Setting {
        let setting = Setting()
        setting.binMask = getBinMaskFromPXBin(pxSetting.bin)
        setting.cardNumber = getCardNumberFromPXCardNumber(pxSetting.cardNumber)
        setting.securityCode = getSecurityCodeFromPXSecurityCode(pxSetting.securityCode)
        return setting
    }

    open func getFinancialInstitutionFromPXFinancialInstitution(_ pxFinancialInstitution: PXFinancialInstitution?) -> FinancialInstitution {
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

    open func getBinMaskFromPXBin(_ pxBin: PXBin?) -> BinMask {
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

    open func getCardNumberFromPXCardNumber(_ pxCardNumber: PXCardNumber) -> CardNumber {
        let cardNumber = CardNumber()
        cardNumber.length = pxCardNumber.length
        cardNumber.validation = pxCardNumber.validation
        return cardNumber
    }

    open func getSecurityCodeFromPXSecurityCode(_ pxSecurityCode: PXSecurityCode) -> SecurityCode {
        let securityCode = SecurityCode()
        securityCode.length = pxSecurityCode.length
        securityCode.cardLocation = pxSecurityCode.cardLocation
        securityCode.mode = pxSecurityCode.mode
        return securityCode
    }

    open func getIdentificationTypeFromPXIdentificationType(_ pxIdentificationType: PXIdentificationType) -> IdentificationType {
        let identificationType = IdentificationType()
        identificationType._id = pxIdentificationType.id
        identificationType.name = pxIdentificationType.name
        identificationType.type = pxIdentificationType.type
        identificationType.minLength = pxIdentificationType.minLength
        identificationType.maxLength = pxIdentificationType.maxLength
        return identificationType
    }

    open func getDiscountCouponFromPXDiscount(_ pxDiscount: PXDiscount) -> DiscountCoupon {
        let discountCoupon = DiscountCoupon()
        discountCoupon._id = pxDiscount.id
        discountCoupon.name = pxDiscount.name
        discountCoupon.percent_off = String(pxDiscount.percentOff)
        discountCoupon.amount_off = String(pxDiscount.amountOff)
        discountCoupon.coupon_amount = String(pxDiscount.couponAmount)
        discountCoupon.currency_id = pxDiscount.currencyId
        discountCoupon.concept = pxDiscount.concept
        return discountCoupon
    }

    open func getPaymentFromPXPayment(_ pxPayment: PXPayment) -> Payment {
        let payment = Payment()
        payment.binaryMode = pxPayment.binaryMode
        payment.callForAuthorizeId = pxPayment.callForAuthorizeId
        payment.captured = pxPayment.captured
        payment.card = getCardFromPXCard(pxPayment.card)
        payment.currencyId = pxPayment.currencyId
        payment.dateApproved = pxPayment.dateApproved
        payment.dateCreated = pxPayment.dateCreated
        payment.dateLastUpdated = pxPayment.dateLastUpdated
        payment._description = pxPayment._description
        payment.externalReference = pxPayment.externalReference
        
        for pxFeeDetail in pxPayment.feeDetails {
            let feesDetail = getFeesDetailFromPXFeeDetail(pxFeeDetail)
            payment.feesDetails = Array.safeAppend(payment.feesDetails, feesDetail)
        }
        
        payment._id = pxPayment.id
        payment.installments = pxPayment.installments
        payment.liveMode = pxPayment.liveMode
        payment.metadata = pxPayment.metadata! as NSObject
        payment.moneyReleaseDate = pxPayment.moneyReleaseDate
        payment.notificationUrl = pxPayment.notificationUrl
        payment.order = getOrderFromPXOrder(pxPayment.order)
        payment.payer = getPayerFromPXPayer(pxPayment.payer)
        payment.paymentMethodId = pxPayment.paymentMethodId
        payment.paymentTypeId = pxPayment.paymentTypeId
        
        for pxRefund in pxPayment.refunds {
            let refund = getRefundFromPXRefund(pxRefund)
            payment.refunds = Array.safeAppend(payment.refunds, refund)
        }
        
        payment.statementDescriptor = pxPayment.statementDescriptor
        payment.status = pxPayment.status
        payment.statusDetail = pxPayment.statusDetail
        payment.transactionAmount = pxPayment.transactionAmount
        payment.transactionAmountRefunded = pxPayment.transactionAmountRefunded
        payment.transactionDetails = getTransactionDetailsFromPXTransactionDetails(pxPayment.transactionDetails)
        payment.collectorId = pxPayment.collectorId
        payment.couponAmount = pxPayment.couponAmount
        payment.differentialPricingId = NSNumber(value: pxPayment.differentialPricingId)
        payment.issuerId = pxPayment.issuerId
        payment.tokenId = pxPayment.tokenId
        return payment
    }
    
    open func getFeesDetailFromPXFeeDetail(_ pxFeeDetail: PXFeeDetail) -> FeesDetail {
        let feesDetail = FeesDetail()
        feesDetail.amount = pxFeeDetail.amount
        feesDetail.feePayer = pxFeeDetail.feePayer
        feesDetail.type = pxFeeDetail.type
        return feesDetail
    }
    
    open func getOrderFromPXOrder(_ pxOrder: PXOrder) -> Order {
        let order = Order()
        order._id = Int(pxOrder.id)!
        order.type = pxOrder.type
        return order
    }
    
    open func getRefundFromPXRefund(_ pxRefund: PXRefund) -> Refund {
        let refund = Refund()
        refund.dateCreated = pxRefund.dateCreated
        refund._id = Int(pxRefund.id)!
        refund.metadata = pxRefund.metadata! as NSObject
        refund.paymentId = Int(pxRefund.paymentId)
        refund.source = pxRefund.source
        refund.uniqueSequenceNumber = pxRefund.uniqueSecuenceNumber
        return refund
    }
    
    open func getTransactionDetailsFromPXTransactionDetails(_ pxTransactionDetails: PXTransactionDetails) -> TransactionDetails {
        let transactionDetails = TransactionDetails()
        transactionDetails.couponAmount = nil
        transactionDetails.externalResourceUrl = pxTransactionDetails.externalResourceUrl
        transactionDetails.financialInstitution = getFinancialInstitutionFromId(pxTransactionDetails.financialInstitution) // TODO AUGUSTO: PORQUE ES UN STRING Y NO UN PXFINANCIALINSTUTION???
        transactionDetails.installmentAmount = pxTransactionDetails.installmentAmount
        transactionDetails.netReceivedAmount = pxTransactionDetails.netReceivedAmount
        transactionDetails.overpaidAmount = pxTransactionDetails.overpaidAmount
        transactionDetails.totalPaidAmount = pxTransactionDetails.totalPaidAmount
        return transactionDetails
    }
    
    open func getFinancialInstitutionFromId(_ financialInstitutionId: String) -> FinancialInstitution {
        let financialInstitution = FinancialInstitution()
        financialInstitution._id = Int(financialInstitutionId)
        return financialInstitution
    }

    open func getPXPayerFromPayer(_ payer: Payer) -> PXPayer {
        let pxPayer = PXPayer(id: "String", accessToken: "String", identification: nil, type: nil, entityType: nil, email: nil, firstName: nil, lastName: nil)
        pxPayer.id = payer._id
        pxPayer.accessToken = MercadoPagoContext.payerAccessToken()
        pxPayer.identification = getPXIdentificationFromIdentification(payer.identification)
        pxPayer.entityType = payer.entityType?._id
        pxPayer.email = payer.email
        pxPayer.firstName = payer.name
        pxPayer.lastName = payer.surname
        return pxPayer
    }

    open func getPayerFromPXPayer(_ pxPayer: PXPayer) -> Payer {
        let payer = Payer()
        payer.email = pxPayer.email
        payer._id = pxPayer.id
        payer.identification = getIdentificationFromPXIdentification(pxPayer.identification)
        payer.entityType = getEntityTypeFromId(pxPayer.entityType)
        payer.name = pxPayer.firstName
        payer.surname = pxPayer.lastName
        payer.address = nil
        return payer
    }

    open func getIdentificationFromPXIdentification(_ pxIdentification: PXIdentification?) -> Identification? {
        if let pxIdentification = pxIdentification, let type = pxIdentification.type, let number = pxIdentification.number {
            let identification = Identification(type: type, number: number)
            return identification
        } else {
            return nil
        }
    }
    
    open func getPXIdentificationFromIdentification(_ identification: Identification?) -> PXIdentification? {
        if let identification = identification {
            let number: String? = identification.number
            let type: String? = identification.type
            let pxIdentification = PXIdentification(number: number, type: type)
            return pxIdentification
        } else {
            return nil
        }
    }

    open func getEntityTypeFromId(_ entityTypeId: String?) -> EntityType? {
        if let entityTypeId = entityTypeId {
            let entityType = EntityType()
            entityType._id = entityTypeId
            entityType.name = ""
            return entityType
        } else {
            return nil
        }
    }

    open func getPaymentMethodSearchFromPXPaymentMethodSearch(_ pxPaymentMethodSearch: PXPaymentMethodSearch) -> PaymentMethodSearch {
        let paymentMethodSearch = PaymentMethodSearch()

        for pxPaymentMethodSearchItem in pxPaymentMethodSearch.paymentMethodSearchItem {
            let paymentMethodSearchItem = getPaymentMethodSearchItemFromPXPaymentMethodSearchItem(pxPaymentMethodSearchItem)
            paymentMethodSearch.groups = Array.safeAppend(paymentMethodSearch.groups, paymentMethodSearchItem)
        }

        for pxPaymentMethod in pxPaymentMethodSearch.paymentMethods {
            let paymentMethod = getPaymentMethodFromPXPaymentMethod(pxPaymentMethod)
            paymentMethodSearch.paymentMethods = Array.safeAppend(paymentMethodSearch.paymentMethods, paymentMethod)
        }

        for pxCustomOptionSearchItem in pxPaymentMethodSearch.customOptionSearchItems {
            let customerPaymentMethod = getCustomerPaymentMethodFromPXCustomOptionSearchItem(pxCustomOptionSearchItem)
            paymentMethodSearch.customerPaymentMethods = Array.safeAppend(paymentMethodSearch.customerPaymentMethods, customerPaymentMethod)
        }

        for pxCard in pxPaymentMethodSearch.cards {
            let card = getCardFromPXCard(pxCard)
            paymentMethodSearch.cards = Array.safeAppend(paymentMethodSearch.cards, card)
        }

        if let pxDefaultOption = pxPaymentMethodSearch.defaultOption {
            paymentMethodSearch.defaultOption = getPaymentMethodSearchItemFromPXPaymentMethodSearchItem(pxDefaultOption)
        }

        return paymentMethodSearch
    }

    open func getCustomerPaymentMethodFromPXCustomOptionSearchItem(_ pxCustomOptionSearchItem: PXCustomOptionSearchItem) -> CustomerPaymentMethod {
        let id: String = pxCustomOptionSearchItem.id
        let paymentMethodId: String = pxCustomOptionSearchItem.paymentMethodId
        let paymentMethodTypeId: String = pxCustomOptionSearchItem.paymentTypeId
        let description: String = pxCustomOptionSearchItem._description
        let customerPaymentMethod = CustomerPaymentMethod(id: id, paymentMethodId: paymentMethodId, paymentMethodTypeId: paymentMethodTypeId, description: description)
        return customerPaymentMethod
    }

    open func getPaymentMethodSearchItemFromPXPaymentMethodSearchItem(_ pxPaymentMethodSearchItem: PXPaymentMethodSearchItem) -> PaymentMethodSearchItem {
        let paymentMethodSearchItem = PaymentMethodSearchItem()
        paymentMethodSearchItem.idPaymentMethodSearchItem = pxPaymentMethodSearchItem.id
        paymentMethodSearchItem.type = getPaymentMethodSearchItemTypeFromString(pxPaymentMethodSearchItem.type)
        paymentMethodSearchItem._description = pxPaymentMethodSearchItem._description
        paymentMethodSearchItem.comment = pxPaymentMethodSearchItem.comment
        paymentMethodSearchItem.childrenHeader = pxPaymentMethodSearchItem.childrenHeader

        if let pxChildren = pxPaymentMethodSearchItem.children {
            for pxPaymentMethodSearchItem in pxChildren {
                let childrenItem = getPaymentMethodSearchItemFromPXPaymentMethodSearchItem(pxPaymentMethodSearchItem)
                paymentMethodSearchItem.children = Array.safeAppend(paymentMethodSearchItem.children, childrenItem)
            }
        } else {
            paymentMethodSearchItem.children = []
        }

        paymentMethodSearchItem.showIcon = pxPaymentMethodSearchItem.showIcon

        return paymentMethodSearchItem
    }

    open func getPaymentMethodSearchItemTypeFromString(_ typeString: String) -> PaymentMethodSearchItemType {
        switch typeString {
        case PaymentMethodSearchItemType.GROUP.rawValue:
            return PaymentMethodSearchItemType.GROUP
        case PaymentMethodSearchItemType.PAYMENT_METHOD.rawValue:
            return PaymentMethodSearchItemType.PAYMENT_METHOD
        case PaymentMethodSearchItemType.PAYMENT_TYPE.rawValue:
            return PaymentMethodSearchItemType.PAYMENT_TYPE
        default:
            return PaymentMethodSearchItemType.GROUP
        }
    }

    open func getCardFromPXCard(_ pxCard: PXCard) -> Card {
        let card = Card()
        card.cardHolder = getCardholderFromPXCardHolder(pxCard.cardHolder)
        card.customerId = pxCard.customerId
        card.dateCreated = pxCard.dateCreated
        card.dateLastUpdated = nil
        card.expirationMonth = pxCard.expirationMonth
        card.expirationYear = pxCard.expirationYear
        card.firstSixDigits = pxCard.firstSixDigits
        card.idCard = pxCard.id
        card.lastFourDigits = pxCard.lastFourDigits
        card.paymentMethod = getPaymentMethodFromPXPaymentMethod(pxCard.paymentMethod)
        card.issuer = getIssuerFromPXIssuer(pxCard.issuer)
        card.securityCode = getSecurityCodeFromPXSecurityCode(pxCard.securityCode)
        return card
    }

    open func getCustomerFromPXCustomer(_ pxCustomer: PXCustomer) -> Customer {
        let customer = Customer()
        customer.address = getAddressFromPXAddress(pxCustomer.address)

        for pxCard in pxCustomer.cards {
            let card = getCardFromPXCard(pxCard)
            customer.cards = Array.safeAppend(customer.cards, card)
        }

        customer.defaultCard = pxCustomer.defaultCard
        customer._description = pxCustomer._description
        customer.dateCreated = pxCustomer.dateCreated
        customer.dateLastUpdated = pxCustomer.dateLastUpdated
        customer.email = pxCustomer.email
        customer.firstName = pxCustomer.firstName
        customer._id = pxCustomer.id
        customer.identification = getIdentificationFromPXIdentification(pxCustomer.identification)
        customer.lastName = pxCustomer.lastName
        customer.liveMode = pxCustomer.liveMode
        customer.metadata = pxCustomer.metadata as NSDictionary
        customer.phone = getPhoneFromPXPhone(pxCustomer.phone)
        customer.registrationDate = pxCustomer.registrationDate
        return customer
    }

    open func getAddressFromPXAddress(_ pxAddress: PXAddress) -> Address {
        let streetName: String? = pxAddress.streetName
        let streetNumber: NSNumber? = pxAddress.streetNumber != nil ? NSNumber(value: pxAddress.streetNumber!) : nil
        let zipCode: String? = pxAddress.zipCode
        let address = Address(streetName: streetName, streetNumber: streetNumber, zipCode: zipCode)
        return address
    }

    open func getPhoneFromPXPhone(_ pxPhone: PXPhone) -> Phone {
        let phone = Phone()
        phone.areaCode = pxPhone.areaCode
        phone.number = pxPhone.number
        return phone
    }

    open func getIssuerFromPXIssuer(_ pxIssuer: PXIssuer) -> Issuer {
        let issuer = Issuer()
        issuer._id = pxIssuer._id // TODO: Sacar el _
        issuer.name = pxIssuer.name
        return issuer
    }

    open func getInstallmentFromPXInstallment(_ pxInstallment: PXInstallment) -> Installment {
        let installment = Installment()
        installment.issuer = getIssuerFromPXIssuer(pxInstallment.issuer)
        installment.paymentTypeId = pxInstallment.paymentTypeId
        installment.paymentMethodId = pxInstallment.paymentMethodId
        for pxPayerCost in pxInstallment.payerCosts {
            let payerCost = getPayerCostFromPXPayerCost(pxPayerCost)
            installment.payerCosts = Array.safeAppend(installment.payerCosts, payerCost)
        }
        return installment
    }

    open func getPayerCostFromPXPayerCost(_ pxPayerCost: PXPayerCost) -> PayerCost {
        let payerCost = PayerCost()
        payerCost.installmentRate = pxPayerCost.installmentRate
        payerCost.labels = pxPayerCost.labels
        payerCost.minAllowedAmount = pxPayerCost.minAllowedAmount
        payerCost.maxAllowedAmount = pxPayerCost.maxAllowedAmount
        payerCost.recommendedMessage = pxPayerCost.recommendedMessage
        payerCost.installmentAmount = pxPayerCost.installmentAmount
        payerCost.totalAmount = pxPayerCost.totalAmount
        payerCost.installments = pxPayerCost.installments
        return payerCost
    }
}
