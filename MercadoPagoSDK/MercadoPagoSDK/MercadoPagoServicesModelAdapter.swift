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
        let id: String = currency.currencyId
        let description: String = currency.currencyDescription
        let symbol: String = currency.symbol
        let decimalPlaces: Int = currency.decimalPlaces
        let decimalSeparator: String = currency.decimalSeparator
        let thousandSeparator: String = currency.thousandsSeparator
        let pxCurrency = PXCurrency(id: id, description: description, symbol: symbol, decimalPlaces: decimalPlaces, decimalSeparator: decimalSeparator, thousandSeparator: thousandSeparator)
        return pxCurrency
    }

    open func getCurrencyFromPXCurrency(_ pxCurrency: PXCurrency?) -> Currency {
        if let pxCurrency = pxCurrency {
            let currencyId: String = pxCurrency.id
            let description: String = pxCurrency._description ?? ""
            let symbol: String = pxCurrency.symbol ?? "$"
            let decimalPlaces: Int = pxCurrency.decimalPlaces ?? 2
            let decimalSeparator: String = pxCurrency.decimalSeparator ?? ","
            let thousandSeparator: String = pxCurrency.thousandSeparator ?? "."
            let currency = Currency(currencyId: currencyId, description: description, symbol: symbol, decimalPlaces: decimalPlaces, decimalSeparator: decimalSeparator, thousandSeparator: thousandSeparator)
            return currency
        }
        return Currency()
    }

    open func getCheckoutPreferenceFromPXCheckoutPreference(_ pxCheckoutPreference: PXCheckoutPreference) -> CheckoutPreference {
        let checkoutPreference = CheckoutPreference()
        checkoutPreference.preferenceId = pxCheckoutPreference.id
        if let pxCheckoutPreferenceItems = pxCheckoutPreference.items {
            for pxItem in pxCheckoutPreferenceItems {
                let item = getItemFromPXItem(pxItem)
                checkoutPreference.items = Array.safeAppend(checkoutPreference.items, item)
            }
        }
        checkoutPreference.payer = getPayerFromPXPayer(pxCheckoutPreference.payer)
        checkoutPreference.paymentPreference = getPaymentPreferenceFromPXPaymentPreference(pxCheckoutPreference.paymentPreference)
        checkoutPreference.siteId = pxCheckoutPreference.siteId ?? ""
        checkoutPreference.expirationDateFrom = pxCheckoutPreference.expirationDateFrom ?? Date()
        checkoutPreference.expirationDateTo = pxCheckoutPreference.expirationDateTo ?? Date()
        return checkoutPreference
    }

    open func getItemFromPXItem(_ pxItem: PXItem) -> Item {
        let id: String = pxItem.id
        let title: String = pxItem.title ?? ""
        let quantity: Int = pxItem.quantity ?? 1
        let unitPrice: Double = pxItem.unitPrice ?? 0.0
        let description: String = pxItem._description ?? ""
        let currencyId: String = pxItem.currencyId ?? "ARS"
        let picture_URL: String = pxItem.pictureUrl ?? ""
        let item = Item(itemId: id, title: title, quantity: quantity, unitPrice: unitPrice, description: description, currencyId: currencyId)
        item.pictureUrl = picture_URL
        return item
    }

    open func getPaymentPreferenceFromPXPaymentPreference(_ pxPaymentPreference: PXPaymentPreference?) -> PaymentPreference {
        let paymentPreference = PaymentPreference()
        if let pxPaymentPreference = pxPaymentPreference {
            paymentPreference.excludedPaymentMethodIds = Set(pxPaymentPreference.excludedPaymentMethodIds ?? [])
            paymentPreference.excludedPaymentTypeIds = Set(pxPaymentPreference.excludedPaymentTypeIds ?? [])
            paymentPreference.defaultPaymentMethodId = pxPaymentPreference.defaultPaymentMethodId
            paymentPreference.maxAcceptedInstallments = pxPaymentPreference.maxAcceptedInstallments != nil ? pxPaymentPreference.maxAcceptedInstallments! : paymentPreference.maxAcceptedInstallments
            paymentPreference.defaultInstallments = pxPaymentPreference.defaultInstallments != nil ? pxPaymentPreference.defaultInstallments! : paymentPreference.defaultInstallments
            paymentPreference.defaultPaymentTypeId = pxPaymentPreference.defaultPaymentTypeId
        }
        return paymentPreference
    }

    open func getInstructionsInfoFromPXInstructions(_ pxInstructions: PXInstructions) -> InstructionsInfo {
        let instructionsInfo = InstructionsInfo()
        instructionsInfo.amountInfo = getAmountInfoFromPXAmountInfo(pxInstructions.amountInfo)

        if let pxInstructionsInstructions = pxInstructions.instructions {
            for pxInstruction in pxInstructionsInstructions {
                let instruction = getInstructionFromPXInstruction(pxInstruction)
                instructionsInfo.instructions = Array.safeAppend(instructionsInfo.instructions, instruction)
            }
        }

        return instructionsInfo
    }

    open func getInstructionFromPXInstruction(_ pxInstruction: PXInstruction) -> Instruction {
        let instruction = Instruction()
        instruction.title = pxInstruction.title ?? ""
        instruction.subtitle = pxInstruction.subtitle
        instruction.accreditationMessage = pxInstruction.accreditationMessage ?? ""
        instruction.accreditationComment = pxInstruction.accreditationComments

        if let pxInstructionReferences = pxInstruction.references {
            instruction.references = []
            for pxInstructionReference in pxInstructionReferences {
                let instructionReference = getInstructionReferenceFromPXInstructionReference(pxInstructionReference)
                instruction.references = Array.safeAppend(instruction.references, instructionReference)
            }
        }

        instruction.info = pxInstruction.info
        instruction.secondaryInfo = pxInstruction.secondaryInfo
        instruction.tertiaryInfo = pxInstruction.tertiaryInfo

        if let pxInstructionAction = pxInstruction.actions {
            for pxInstructionAction in pxInstructionAction {
                let instructionAction = getInstructionActionFromPXInstructionAction(pxInstructionAction)
                instruction.actions = Array.safeAppend(instruction.actions, instructionAction)
            }
        }

        instruction.type = pxInstruction.type ?? ""
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

    open func getAmountInfoFromPXAmountInfo(_ pxAmountInfo: PXAmountInfo?) -> AmountInfo {
        let amountInfo = AmountInfo()
        if let pxAmountInfo = pxAmountInfo {
            amountInfo.amount = pxAmountInfo.amount
            amountInfo.currency = getCurrencyFromPXCurrency(pxAmountInfo.currency)
        }
        return amountInfo
    }

    open func getPXCardTokenFromCardToken(_ cardToken: CardToken) -> PXCardToken {
        let pxCardToken = PXCardToken()
        pxCardToken.cardholder = getPXCardHolderFromCardHolder(cardToken.cardholder!)
        pxCardToken.cardNumber = cardToken.cardNumber
        pxCardToken.device = getPXDeviceFromDevice(cardToken.device)
        pxCardToken.expirationMonth = cardToken.expirationMonth
        pxCardToken.expirationYear = cardToken.expirationYear
        pxCardToken.securityCode = cardToken.securityCode
        return pxCardToken
    }

    open func getPXSavedESCCardTokenFromSavedESCCardToken(_ savedESCCardToken: SavedESCCardToken) -> PXSavedESCCardToken {
        let pxSavedESCCardToken = PXSavedESCCardToken()
        pxSavedESCCardToken.cardId = savedESCCardToken.cardId
        pxSavedESCCardToken.securityCode = savedESCCardToken.securityCode
        pxSavedESCCardToken.device = PXDevice()
        pxSavedESCCardToken.requireEsc = savedESCCardToken.requireESC
        pxSavedESCCardToken.esc = savedESCCardToken.esc
        return pxSavedESCCardToken
    }

    open func getPXSavedCardTokenFromSavedCardToken(_ savedCardToken: SavedCardToken) -> PXSavedCardToken {
        let pxSavedCardToken = PXSavedCardToken()
        pxSavedCardToken.cardId = savedCardToken.cardId
        pxSavedCardToken.securityCode = savedCardToken.securityCode
        pxSavedCardToken.device = getPXDeviceFromDevice(savedCardToken.device)
        return pxSavedCardToken
    }

    open func getPXDeviceFromDevice(_ device: Device?) -> PXDevice {
        if let device = device {
            let pxDevice = PXDevice()
            pxDevice.fingerprint = getPXFingerprintFromFingerprint(device.fingerprint)
            return pxDevice
        } else {
            return PXDevice()
        }
    }

    open func getPXFingerprintFromFingerprint(_ fingerprint: Fingerprint) -> PXFingerprint {
        let pxFingerprint = PXFingerprint()
        return pxFingerprint
    }

    open func getTokenFromPXToken(_ pxToken: PXToken) -> Token {
        let id: String = pxToken.id
        let publicKey: String = pxToken.publicKey ?? ""
        let cardId: String = pxToken.cardId ?? ""
        let luhnValidation: String = pxToken.luhnValidation?.description ?? ""
        let status: String = pxToken.status ?? ""
        let usedDate: String = getStringDateFromDate(pxToken.usedDate ?? Date())
        let cardNumberLength: Int = pxToken.cardNumberLength ?? 0
        let creationDate: Date = pxToken.dateCreated ?? Date()
        let lastFourDigits: String = pxToken.lastFourDigits ?? ""
        let firstSixDigits: String = pxToken.firstSixDigits ?? ""
        let securityCodeLength: Int = pxToken.securityCodeLength ?? 0
        let expirationMonth: Int = pxToken.expirationMonth  ?? 0
        let expirationYear: Int = pxToken.expirationYear ?? 0
        let lastModifiedDate: Date = pxToken.dateLastUpdated ?? Date()
        let dueDate: Date = pxToken.dueDate ?? Date()
        let cardholder = getCardholderFromPXCardHolder(pxToken.cardholder)
        let esc = pxToken.esc
        let token = Token(tokenId: id, publicKey: publicKey, cardId: cardId, luhnValidation: luhnValidation, status: status, usedDate: usedDate, cardNumberLength: cardNumberLength, creationDate: creationDate, lastFourDigits: lastFourDigits, firstSixDigit: firstSixDigits, securityCodeLength: securityCodeLength, expirationMonth: expirationMonth, expirationYear: expirationYear, lastModifiedDate: lastModifiedDate, dueDate: dueDate, cardHolder: cardholder)
        token.esc = esc
        return token
    }

    open func getStringDateFromDate(_ date: Date) -> String {
        let stringDate = String(describing: date)
        return stringDate
    }

    open func getCardholderFromPXCardHolder(_ pxCardHolder: PXCardHolder?) -> Cardholder {
        let cardholder = Cardholder()
        if let pxCardHolder = pxCardHolder {
            cardholder.name = pxCardHolder.name
            cardholder.identification = getIdentificationFromPXIdentification(pxCardHolder.identification)
        }
        return cardholder
    }

    open func getPXCardHolderFromCardHolder(_ cardHolder: Cardholder) -> PXCardHolder {
        let name: String = cardHolder.name!
        let pxIdentification: PXIdentification = getPXIdentificationFromIdentification(cardHolder.identification)!
        let pxCardholder = PXCardHolder(name: name, identification: pxIdentification)
        return pxCardholder
    }

    open func getBankDealFromPXBankDeal(_ pxBankDeal: PXBankDeal) -> BankDeal {
        let bankDeal = BankDeal()
        bankDeal.promoId = pxBankDeal.id
        bankDeal.issuer = getIssuerFromPXIssuer(pxBankDeal.issuer)
        bankDeal.recommendedMessage = pxBankDeal.recommendedMessage

        if let pxBankDealPaymentMethods = pxBankDeal.paymentMethods {
            bankDeal.paymentMethods = []
            for pxPaymentMethod in pxBankDealPaymentMethods {
                let paymentMethod = getPaymentMethodFromPXPaymentMethod(pxPaymentMethod)
                bankDeal.paymentMethods = Array.safeAppend(bankDeal.paymentMethods, paymentMethod)
            }
        }

        bankDeal.legals = pxBankDeal.legals
        bankDeal.url = pxBankDeal.picture?.url ?? ""
        return bankDeal
    }

    open func getPaymentMethodFromPXPaymentMethod(_ pxPaymentMethod: PXPaymentMethod?) -> PaymentMethod {
        let paymentMethod = PaymentMethod()
        if let pxPaymentMethod = pxPaymentMethod {
            paymentMethod.paymentMethodId = pxPaymentMethod.id
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
        }
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
            financialInstitution.financialInstitutionId = Int(pxFinancialInstitution.id)
            financialInstitution.financialInstitutionDescription = pxFinancialInstitution._description
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

    open func getCardNumberFromPXCardNumber(_ pxCardNumber: PXCardNumber?) -> CardNumber {
        let cardNumber = CardNumber()
        if let pxCardNumber = pxCardNumber {
            cardNumber.length = pxCardNumber.length ?? 17
            cardNumber.validation = pxCardNumber.validation
        }
        return cardNumber
    }

    open func getSecurityCodeFromPXSecurityCode(_ pxSecurityCode: PXSecurityCode?) -> SecurityCode {
        let securityCode = SecurityCode()
        if let pxSecurityCode = pxSecurityCode {
            securityCode.length = pxSecurityCode.length ?? 3
            securityCode.cardLocation = pxSecurityCode.cardLocation
            securityCode.mode = pxSecurityCode.mode
        }
        return securityCode
    }

    open func getIdentificationTypeFromPXIdentificationType(_ pxIdentificationType: PXIdentificationType) -> IdentificationType {
        let identificationType = IdentificationType()
        identificationType.identificationTypeId = pxIdentificationType.id
        identificationType.name = pxIdentificationType.name
        identificationType.type = pxIdentificationType.type
        identificationType.minLength = pxIdentificationType.minLength ?? 0
        identificationType.maxLength = pxIdentificationType.maxLength ?? 0
        return identificationType
    }

    open func getDiscountCouponFromPXDiscount(_ pxDiscount: PXDiscount, amount: Double) -> DiscountCoupon {
        let discountCoupon = DiscountCoupon(discountId: UInt(pxDiscount.id) ?? 0)
        discountCoupon.name = pxDiscount.name
        discountCoupon.percent_off = pxDiscount.percentOff?.cleanString ?? "0"
        discountCoupon.amount_off = pxDiscount.amountOff?.cleanString ?? "0"
        discountCoupon.coupon_amount = pxDiscount.couponAmount?.cleanString ?? "0"
        discountCoupon.currency_id = pxDiscount.currencyId
        discountCoupon.concept = pxDiscount.concept
        discountCoupon.amountWithoutDiscount = amount
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
        payment.paymentDescription = pxPayment._description
        payment.externalReference = pxPayment.externalReference

        if let pxPaymentFeeDetails = pxPayment.feeDetails {
            for pxFeeDetail in pxPaymentFeeDetails {
                let feesDetail = getFeesDetailFromPXFeeDetail(pxFeeDetail)
                payment.feesDetails = Array.safeAppend(payment.feesDetails, feesDetail)
            }
        }

        payment.paymentId = pxPayment.id.stringValue
        payment.installments = pxPayment.installments ?? 1
        payment.liveMode = pxPayment.liveMode
        payment.metadata = pxPayment.metadata! as NSObject
        payment.moneyReleaseDate = pxPayment.moneyReleaseDate
        payment.notificationUrl = pxPayment.notificationUrl
        payment.order = getOrderFromPXOrder(pxPayment.order)
        payment.payer = getPayerFromPXPayer(pxPayment.payer)
        payment.paymentMethodId = pxPayment.paymentMethodId
        payment.paymentTypeId = pxPayment.paymentTypeId

        if let pxPaymentRefunds = pxPayment.refunds {
            for pxRefund in pxPaymentRefunds {
                let refund = getRefundFromPXRefund(pxRefund)
                payment.refunds = Array.safeAppend(payment.refunds, refund)
            }
        }

        payment.statementDescriptor = pxPayment.statementDescriptor
        payment.status = pxPayment.status
        payment.statusDetail = pxPayment.statusDetail
        payment.transactionAmount = pxPayment.transactionAmount ?? 0.0
        payment.transactionAmountRefunded = pxPayment.transactionAmountRefunded ?? 0.0
        payment.transactionDetails = getTransactionDetailsFromPXTransactionDetails(pxPayment.transactionDetails)
        payment.collectorId = String(describing: pxPayment.collectorId)
        payment.couponAmount = pxPayment.couponAmount ?? 0.0
        payment.differentialPricingId = NSNumber(value: pxPayment.differentialPricingId ?? 0)
        payment.issuerId = Int(pxPayment.issuerId ?? "0") ?? 0
        payment.tokenId = pxPayment.tokenId
        return payment
    }

    open func getFeesDetailFromPXFeeDetail(_ pxFeeDetail: PXFeeDetail) -> FeesDetail {
        let feesDetail = FeesDetail()
        feesDetail.amount = pxFeeDetail.amount ?? 0.0
        feesDetail.feePayer = pxFeeDetail.feePayer
        feesDetail.type = pxFeeDetail.type
        return feesDetail
    }

    open func getOrderFromPXOrder(_ pxOrder: PXOrder?) -> Order {
        let order = Order()
        if let pxOrder = pxOrder {
            order.orderId = Int(pxOrder.id ?? "0") ?? 0 //TODO AUGUSTO: ARREGLAR ESTO
            order.type = pxOrder.type
        }
        return order
    }

    open func getRefundFromPXRefund(_ pxRefund: PXRefund) -> Refund {
        let refund = Refund()
        refund.dateCreated = pxRefund.dateCreated
        refund.refundId = Int(pxRefund.id)!
        refund.metadata = pxRefund.metadata! as NSObject
        refund.paymentId = pxRefund.paymentId != nil ? pxRefund.paymentId! : 0
        refund.source = pxRefund.source
        refund.uniqueSequenceNumber = pxRefund.uniqueSecuenceNumber
        return refund
    }

    open func getTransactionDetailsFromPXTransactionDetails(_ pxTransactionDetails: PXTransactionDetails?) -> TransactionDetails {
        let transactionDetails = TransactionDetails()
        if let pxTransactionDetails = pxTransactionDetails {
            transactionDetails.couponAmount = nil
            transactionDetails.externalResourceUrl = pxTransactionDetails.externalResourceUrl
            transactionDetails.financialInstitution = getFinancialInstitutionFromId(pxTransactionDetails.financialInstitution)
            transactionDetails.installmentAmount = pxTransactionDetails.installmentAmount
            transactionDetails.netReceivedAmount = pxTransactionDetails.netReceivedAmount
            transactionDetails.overpaidAmount = pxTransactionDetails.overpaidAmount
            transactionDetails.totalPaidAmount = pxTransactionDetails.totalPaidAmount
        }
        return transactionDetails
    }

    open func getFinancialInstitutionFromId(_ financialInstitutionId: String?) -> FinancialInstitution {
        let financialInstitution = FinancialInstitution()
        if let financialInstitutionId = financialInstitutionId {
            financialInstitution.financialInstitutionId = Int(financialInstitutionId)
        }
        return financialInstitution
    }

    open func getPXPayerFromPayer(_ payer: Payer) -> PXPayer {
        let pxPayer = PXPayer(id: "String", accessToken: "String", identification: nil, type: nil, entityType: nil, email: nil, firstName: nil, lastName: nil)
        pxPayer.id = payer.payerId
        pxPayer.accessToken = MercadoPagoContext.payerAccessToken()
        pxPayer.identification = getPXIdentificationFromIdentification(payer.identification)
        pxPayer.entityType = payer.entityType?.entityTypeId
        pxPayer.email = payer.email
        pxPayer.firstName = payer.name
        pxPayer.lastName = payer.surname
        return pxPayer
    }

    open func getPayerFromPXPayer(_ pxPayer: PXPayer?) -> Payer {
        let payer = Payer()
        if let pxPayer = pxPayer {
            payer.email = pxPayer.email
            payer.payerId = pxPayer.id
            payer.identification = getIdentificationFromPXIdentification(pxPayer.identification)
            payer.entityType = getEntityTypeFromId(pxPayer.entityType)
            payer.name = pxPayer.firstName
            payer.surname = pxPayer.lastName
            payer.address = nil
        }
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
            let number: String = !String.isNullOrEmpty(identification.number) ? identification.number! : "null"
            let type: String = !String.isNullOrEmpty(identification.type) ? identification.type! : "null"
            let pxIdentification = PXIdentification(number: number, type: type)
            return pxIdentification
        } else {
            return nil
        }
    }

    open func getEntityTypeFromId(_ entityTypeId: String?) -> EntityType? {
        if let entityTypeId = entityTypeId {
            let entityType = EntityType()
            entityType.entityTypeId = entityTypeId
            entityType.name = ""
            return entityType
        } else {
            return nil
        }
    }

    open func getPaymentMethodSearchFromPXPaymentMethodSearch(_ pxPaymentMethodSearch: PXPaymentMethodSearch) -> PaymentMethodSearch {
        let paymentMethodSearch = PaymentMethodSearch()

        if let pxPaymentMethodSearchPaymentMethodSearchItem = pxPaymentMethodSearch.paymentMethodSearchItem {
            paymentMethodSearch.groups = []
            for pxPaymentMethodSearchItem in pxPaymentMethodSearchPaymentMethodSearchItem {
                let paymentMethodSearchItem = getPaymentMethodSearchItemFromPXPaymentMethodSearchItem(pxPaymentMethodSearchItem)
                paymentMethodSearch.groups = Array.safeAppend(paymentMethodSearch.groups, paymentMethodSearchItem)
            }
        }

        if let pxPaymentMethodSearchPaymentMethods = pxPaymentMethodSearch.paymentMethods {
            paymentMethodSearch.paymentMethods = []
            for pxPaymentMethod in pxPaymentMethodSearchPaymentMethods {
                let paymentMethod = getPaymentMethodFromPXPaymentMethod(pxPaymentMethod)
                paymentMethodSearch.paymentMethods = Array.safeAppend(paymentMethodSearch.paymentMethods, paymentMethod)
            }
        }

        if let pxPaymentMethodSearchCards = pxPaymentMethodSearch.cards {
            paymentMethodSearch.cards = []
            for pxCard in pxPaymentMethodSearchCards {
                let card = getCardFromPXCard(pxCard)
                paymentMethodSearch.cards = Array.safeAppend(paymentMethodSearch.cards, card)
            }
        }

        if let pxPaymentMethodSearchCustomOptionSearchItems = pxPaymentMethodSearch.customOptionSearchItems {
            paymentMethodSearch.customerPaymentMethods = []
            for pxCustomOptionSearchItem in pxPaymentMethodSearchCustomOptionSearchItems {
                let customerPaymentMethod = getCustomerPaymentMethodFromPXCustomOptionSearchItem(pxCustomOptionSearchItem)
                if let paymentMethodSearchCards = paymentMethodSearch.cards {
                    var filteredCustomerCard = paymentMethodSearchCards.filter({return $0.idCard == customerPaymentMethod.customerPaymentMethodId})
                    if !Array.isNullOrEmpty(filteredCustomerCard) {
                        customerPaymentMethod.card = filteredCustomerCard[0]
                    }
                }
                paymentMethodSearch.customerPaymentMethods = Array.safeAppend(paymentMethodSearch.customerPaymentMethods, customerPaymentMethod)
            }
        }

        if let pxDefaultOption = pxPaymentMethodSearch.defaultOption {
            paymentMethodSearch.defaultOption = getPaymentMethodSearchItemFromPXPaymentMethodSearchItem(pxDefaultOption)
        }

        return paymentMethodSearch
    }

    open func getCustomerPaymentMethodFromPXCustomOptionSearchItem(_ pxCustomOptionSearchItem: PXCustomOptionSearchItem) -> CustomerPaymentMethod {
        let id: String = pxCustomOptionSearchItem.id
        let paymentMethodId: String = pxCustomOptionSearchItem.paymentMethodId ?? ""
        let paymentMethodTypeId: String = pxCustomOptionSearchItem.paymentTypeId ?? ""
        let description: String = pxCustomOptionSearchItem._description ?? ""
        let customerPaymentMethod = CustomerPaymentMethod(cPaymentMethodId: id, paymentMethodId: paymentMethodId, paymentMethodTypeId: paymentMethodTypeId, description: description)
        return customerPaymentMethod
    }

    open func getPaymentMethodSearchItemFromPXPaymentMethodSearchItem(_ pxPaymentMethodSearchItem: PXPaymentMethodSearchItem) -> PaymentMethodSearchItem {
        let paymentMethodSearchItem = PaymentMethodSearchItem()
        paymentMethodSearchItem.idPaymentMethodSearchItem = pxPaymentMethodSearchItem.id
        paymentMethodSearchItem.type = getPaymentMethodSearchItemTypeFromString(pxPaymentMethodSearchItem.type)
        paymentMethodSearchItem.paymentMethodSearchItemDescription = pxPaymentMethodSearchItem._description
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

        paymentMethodSearchItem.showIcon = pxPaymentMethodSearchItem.showIcon ?? true

        return paymentMethodSearchItem
    }

    open func getPaymentMethodSearchItemTypeFromString(_ typeString: String?) -> PaymentMethodSearchItemType {
        if let typeString = typeString {
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
        } else {
            return PaymentMethodSearchItemType.GROUP
        }
    }

    open func getCardFromPXCard(_ pxCard: PXCard?) -> Card {
        let card = Card()
        if let pxCard = pxCard {
            card.cardHolder = getCardholderFromPXCardHolder(pxCard.cardHolder)
            card.customerId = pxCard.customerId
            card.dateCreated = pxCard.dateCreated
            card.dateLastUpdated = pxCard.dateLastUpdated
            card.expirationMonth = pxCard.expirationMonth ?? 0
            card.expirationYear = pxCard.expirationYear ?? 0
            card.firstSixDigits = pxCard.firstSixDigits
            card.idCard = pxCard.id ?? ""
            card.lastFourDigits = pxCard.lastFourDigits
            card.paymentMethod = getPaymentMethodFromPXPaymentMethod(pxCard.paymentMethod)
            card.issuer = getIssuerFromPXIssuer(pxCard.issuer)
            card.securityCode = getSecurityCodeFromPXSecurityCode(pxCard.securityCode)
            return card
        }
        return card
    }

    open func getCustomerFromPXCustomer(_ pxCustomer: PXCustomer) -> Customer {
        let customer = Customer()
        customer.address = getAddressFromPXAddress(pxCustomer.address)

        if let pxCustomerCards = pxCustomer.cards {
            customer.cards = []
            for pxCard in pxCustomerCards {
                let card = getCardFromPXCard(pxCard)
                customer.cards = Array.safeAppend(customer.cards, card)
            }
        }

        customer.defaultCard = pxCustomer.defaultCard
        customer.customerDescription = pxCustomer._description
        customer.dateCreated = pxCustomer.dateCreated
        customer.dateLastUpdated = pxCustomer.dateLastUpdated
        customer.email = pxCustomer.email
        customer.firstName = pxCustomer.firstName
        customer.customerId = pxCustomer.id
        customer.identification = getIdentificationFromPXIdentification(pxCustomer.identification)
        customer.lastName = pxCustomer.lastName
        customer.liveMode = pxCustomer.liveMode
        customer.phone = getPhoneFromPXPhone(pxCustomer.phone)
        customer.registrationDate = pxCustomer.registrationDate

        if let meta = pxCustomer.metadata {
            customer.metadata = meta as NSDictionary
        }
        return customer
    }

    open func getAddressFromPXAddress(_ pxAddress: PXAddress?) -> Address {
        if let pxAddress = pxAddress {
            let streetName: String? = pxAddress.streetName
            let streetNumber: NSNumber? = pxAddress.streetNumber != nil ? NSNumber(value: pxAddress.streetNumber!) : nil
            let zipCode: String? = pxAddress.zipCode
            let address = Address(streetName: streetName, streetNumber: streetNumber, zipCode: zipCode)
            return address
         }
        return Address()
    }

    open func getPhoneFromPXPhone(_ pxPhone: PXPhone?) -> Phone {
        let phone = Phone()
        if let pxPhone = pxPhone {
            phone.areaCode = pxPhone.areaCode
            phone.number = pxPhone.number
        }
        return phone
    }

    open func getIssuerFromPXIssuer(_ pxIssuer: PXIssuer?) -> Issuer {
        let issuer = Issuer()
        if let pxIssuer = pxIssuer {
            issuer.issuerId = pxIssuer.id
            issuer.name = pxIssuer.name
        }
        return issuer
    }

    open func getInstallmentFromPXInstallment(_ pxInstallment: PXInstallment) -> Installment {
        let installment = Installment()
        installment.issuer = getIssuerFromPXIssuer(pxInstallment.issuer)
        installment.paymentTypeId = pxInstallment.paymentTypeId
        installment.paymentMethodId = pxInstallment.paymentMethodId

        if let pxInstallmentPayerCosts = pxInstallment.payerCosts {
            installment.payerCosts = []
            for pxPayerCost in pxInstallmentPayerCosts {
                let payerCost = getPayerCostFromPXPayerCost(pxPayerCost)
                installment.payerCosts = Array.safeAppend(installment.payerCosts, payerCost)
            }
        }
        return installment
    }

    open func getPayerCostFromPXPayerCost(_ pxPayerCost: PXPayerCost?) -> PayerCost {
        let payerCost = PayerCost()
        if let pxPayerCost = pxPayerCost {
            payerCost.installmentRate = pxPayerCost.installmentRate ?? 0.0
            payerCost.labels = pxPayerCost.labels
            payerCost.minAllowedAmount = pxPayerCost.minAllowedAmount ?? 1
            payerCost.maxAllowedAmount = pxPayerCost.maxAllowedAmount ?? 1000000
            payerCost.recommendedMessage = pxPayerCost.recommendedMessage
            payerCost.installmentAmount = pxPayerCost.installmentAmount ?? 1000
            payerCost.totalAmount = pxPayerCost.totalAmount ?? 1000
            payerCost.installments = pxPayerCost.installments ?? 1
        }
        return payerCost
    }
}
