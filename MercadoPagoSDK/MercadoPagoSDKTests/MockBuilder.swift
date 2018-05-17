//
//  MockBuilder.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 22/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoServices

open class MockBuilder: NSObject {

    internal class var MOCK_PAYMENT_ID: String {
        return "1826290155"
    }

    class var PREF_ID_NO_EXCLUSIONS: String {
        return "NO_EXCLUSIONS"
    }

    class var PREF_ID_CC: String {
        return "ONLY_CREDIT_CARD"
    }

    class var PREF_ID_TICKET: String {
        return "ONLY_TICKET"
    }

    class var PREF_ID_PAGOFACIL: String {
        return "ONLY_PAGOFACIL"
    }

    class var MLA_PK: String {
        return "PK_MLA"
    }

    class var MLA_CURRENCY: String {
        return "ARS"
    }

    class var MLA_PAYMENT_TYPES: Set<String> {
        return [PaymentTypeId.CREDIT_CARD.rawValue, PaymentTypeId.TICKET.rawValue, PaymentTypeId.BANK_TRANSFER.rawValue]
    }

    class var MERCHANT_ACCESS_TOKEN: String {
        return "MERCHANT_ACCESS_TOKEN"
    }

    class var CUSTOMER_ACCESS_TOKEN: String {
        return "ACCESS_TOKEN"
    }

    class var INSTALLMENT_AMOUNT: Double {
        return 100.0
    }

    class var AMEX_TEST_CARD_NUMBER: String {
        return "371180303257522"
    }

    class var MASTER_TEST_CARD_NUMBER: String {
        return "5031755734530604"
    }

    class var VISA_TEST_CARD_NUMBER: String {
        return "4170068810108020"
    }

    static let TEN = "10.00"
    static let HUNDRED = "100.00"
    static let THOUSAND = "1000.00"
    static let TEN_THOUSAND = "10000.00"
    static let MILLON = "1000000.00"
    static let OVER_MILLON = "10000000000.00"
    static let MILLIONS = "10000000000000000.00"

    static let HALF_HOUR_IN_MINS = 30 * 1000
    static let ONE_HOUR_IN_MINS = 60 * 1000
    static let TWENTY_HOURS_AND_FIFTEEN_MINS_IN_MINS = 1395 * 1000
    static let ONE_DAY_IN_MINS = 1440 * 1000
    static let TWO_DAY_IN_MINS = 2880 * 1000
    static let SEVEN_DAY_IN_MINS = 10080 * 1000
    static let HUNDRED_DAYS_IN_MINS = 144000 * 1000

    class func buildCheckoutPreference() -> CheckoutPreference {
        let preference = CheckoutPreference()
        preference.preferenceId = PREF_ID_NO_EXCLUSIONS
        preference.items = [self.buildItem("itemId", quantity: 1, unitPrice: 2559), self.buildItem("itemId2", quantity: 2, unitPrice: 10)]
        return preference
    }

    class func buildItem(_ id: String, quantity: Int, unitPrice: Double, description: String? = "Description") -> Item {
        return Item(itemId: id, title: "item title", quantity: quantity, unitPrice: unitPrice, description: description)
    }

    class func buildPayer(_ id: String) -> Payer {
        let payer =  Payer()
        payer.payerId = id
        payer.email = "thisisanem@il.com"
        return payer
    }

    class func buildPreferencePaymentMethods() -> PaymentPreference {
        let preferencePM = PaymentPreference()
        preferencePM.defaultInstallments = 1
        preferencePM.defaultPaymentMethodId = "visa"
        preferencePM.excludedPaymentMethodIds = ["amex"]
        preferencePM.excludedPaymentTypeIds = self.getMockPaymentTypeIds()
        return preferencePM
    }

    class func buildPaymentMethod(_ id: String, name: String? = "", paymentTypeId: String? = "credit_card", multipleSettings: Bool = false) -> PaymentMethod {
        let paymentMethod = PaymentMethod()
        paymentMethod.paymentMethodId = id
        paymentMethod.name = name
        paymentMethod.paymentTypeId = paymentTypeId
        paymentMethod.additionalInfoNeeded = ["info"]

        if multipleSettings {
            paymentMethod.settings = [MockBuilder.buildSetting(), MockBuilder.buildSetting()]
        } else {
            paymentMethod.settings = [MockBuilder.buildSetting()]
        }

        return paymentMethod
    }

    class func buildSecurityCode() -> SecurityCode {
        let securityCode = SecurityCode()
        securityCode.length = 3
        securityCode.mode = "mode"
        securityCode.cardLocation = "back"
        return securityCode
    }

    class func buildSetting() -> Setting {
        let setting = Setting()
        setting.binMask = MockBuilder.buildBinMask()
        setting.securityCode = MockBuilder.buildSecurityCode()
        setting.cardNumber = MockBuilder.buildCardNumber()
        return setting
    }

    class func buildIdentification() -> Identification {
        let identification = Identification(type: "type", number: "number")
        return identification
    }

    class func buildIdentificationTypes() -> [IdentificationType] {
        let identificationType = IdentificationType()
        return [identificationType]
    }

    class func buildCard(paymentMethodId: String? = "paymentMethodId") -> Card {
        let card = Card()
        card.idCard = "4"
        card.firstSixDigits = "123456"
        card.lastFourDigits = "1234"
        card.expirationMonth = 4
        card.expirationYear = 20
        card.cardHolder = buildCardholder()
        card.securityCode = buildSecurityCode()
        card.securityCode?.cardLocation = "card_location"
        card.securityCode?.mode = "mode"
        card.securityCode?.length = 3
        card.paymentMethod = MockBuilder.buildPaymentMethod(paymentMethodId!)
        card.customerId = "customer_id"
        card.issuer = buildIssuer()
        return card
    }

    class func buildCustomerPaymentMethod(paymentMethodId: String, paymentTypeId: String) -> CustomerPaymentMethod {
        let customerPm = CustomerPaymentMethod()
        let pm = MockBuilder.buildPaymentMethod(paymentMethodId)
        customerPm.paymentMethod = pm
        customerPm.paymentMethodId = paymentMethodId
        customerPm.paymentMethodTypeId = paymentTypeId
        customerPm.customerPaymentMethodDescription = paymentMethodId
        return customerPm
    }

    class func buildPayment(_ paymentMethodId: String, installments: Int? = 1, includeFinancingFee: Bool? = false, status: String? = "approved", statusDetail: String? = "approved") -> Payment {
        let payment = Payment()
        payment.paymentId = self.MOCK_PAYMENT_ID
        payment.paymentMethodId = paymentMethodId
        payment.paymentTypeId = "credit_card"
        payment.status = status
        payment.installments = installments!
        payment.transactionDetails = TransactionDetails()
        payment.transactionDetails.installmentAmount = MockBuilder.INSTALLMENT_AMOUNT
        payment.statusDetail = statusDetail
        payment.feesDetails = [FeesDetail]()
        if includeFinancingFee != nil && includeFinancingFee! {
            let feesDetail = FeesDetail()
            feesDetail.type = "financing_fee"
            payment.feesDetails.append(feesDetail)
            let amount = MockBuilder.INSTALLMENT_AMOUNT * Double(installments!)
            payment.transactionDetails.totalPaidAmount =  amount + (amount * 0.20)
        }
        payment.payer = buildPayer("1")
        payment.card = buildCard()
        return payment
    }

    class func buildOffPayment(_ paymentMethodId: String, paymentTypeId: String? = "ticket") -> Payment {
        let payment = Payment()
        payment.paymentId = self.MOCK_PAYMENT_ID
        payment.paymentMethodId = paymentMethodId
        payment.paymentTypeId = paymentTypeId
        payment.status = "pending"
        return payment
    }

    class func buildMastercardPayment(_ installments: Int? = 1, includeFinancingFee: Bool? = false, status: String? = "approved", statusDetail: String? = "approved") -> Payment {
        return MockBuilder.buildPayment("master", installments: installments, includeFinancingFee: includeFinancingFee, status: status, statusDetail: statusDetail)
    }

    class func buildVisaPayment(_ installments: Int? = 1, includeFinancingFee: Bool? = false, status: String? = "approved", statusDetail: String? = "approved") -> Payment {
        return MockBuilder.buildPayment("visa", installments: installments, includeFinancingFee: includeFinancingFee, status: status, statusDetail: statusDetail)
    }

    class func buildAmexPayment(_ installments: Int? = 1, includeFinancingFee: Bool? = false, status: String? = "approved", statusDetail: String? = "approved") -> Payment {
        return MockBuilder.buildPayment("visa", installments: installments, includeFinancingFee: includeFinancingFee, status: status, statusDetail: statusDetail)
    }

    class func buildPaymentMethodSearchItem(_ paymentMethodId: String, type: PaymentMethodSearchItemType? = nil) -> PaymentMethodSearchItem {
        let paymentMethodSearchItem = PaymentMethodSearchItem()
        paymentMethodSearchItem.idPaymentMethodSearchItem = paymentMethodId
        if type != nil {
            paymentMethodSearchItem.type = type
        }
        paymentMethodSearchItem.showIcon = true
        paymentMethodSearchItem.paymentMethodSearchItemDescription = paymentMethodId
        return paymentMethodSearchItem
    }

    class func buildPaymentMethodPlugin(id: String, name: String, displayOrder: PXPaymentMethodPlugin.DisplayOrder = .TOP, shouldSkipPaymentPlugin: Bool = false, configPaymentMethodPlugin: MockConfigPaymentMethodPlugin?) -> PXPaymentMethodPlugin {
        let paymentPlugin = MockPaymentPluginViewController()

        let plugin = PXPaymentMethodPlugin(paymentMethodPluginId: id, name: name, image: UIImage(), description: nil, paymentPlugin: paymentPlugin)

        if let configPaymentMethodPlugin = configPaymentMethodPlugin {
            plugin.setPaymentMethodConfig(plugin: configPaymentMethodPlugin)
        }

        plugin.setDisplayOrder(order: displayOrder)

        return plugin
    }

    class func buildPaymentPlugin() -> PXPaymentPluginComponent {
        return MockPaymentPluginViewController()
    }

    class func buildPaymentMethodSearch(groups: [PaymentMethodSearchItem]? = nil, paymentMethods: [PaymentMethod]? = nil, customOptions: [CardInformation]? = nil) -> PaymentMethodSearch {
        let paymentMethodSearch = PaymentMethodSearch()
        paymentMethodSearch.groups = groups
        paymentMethodSearch.paymentMethods = paymentMethods
        paymentMethodSearch.customerPaymentMethods = customOptions
        return paymentMethodSearch
    }

    class func buildPaymentMethodSearchComplete() -> PaymentMethodSearch {
        let accountMoneyOption = MockBuilder.buildCustomerPaymentMethod("account_money", paymentMethodId: "account_money")
        let customerCardOption = MockBuilder.buildCustomerPaymentMethod("customerCardId", paymentMethodId: "visa")
        let creditCardOption = MockBuilder.buildPaymentMethodSearchItem("credit_card", type: PaymentMethodSearchItemType.PAYMENT_TYPE)
        let offlineOption = MockBuilder.buildPaymentMethodSearchItem("off", type: PaymentMethodSearchItemType.PAYMENT_METHOD)
        let paymentMethodVisa = MockBuilder.buildPaymentMethod("visa")
        let paymentMethodMaster = MockBuilder.buildPaymentMethod("master")
        let paymentMethodTicket = MockBuilder.buildPaymentMethod("ticket", paymentTypeId: "off")
        let paymentMethodTicket2 = MockBuilder.buildPaymentMethod("ticket 2", paymentTypeId: "off")
        let paymentMethodAM = MockBuilder.buildPaymentMethod("account_money", paymentTypeId: "account_money")
        let offlinePaymentMethod = MockBuilder.buildPaymentMethod("off", paymentTypeId: PaymentTypeId.TICKET.rawValue)

        let paymentMethodSearchMock = MockBuilder.buildPaymentMethodSearch(groups: [creditCardOption, offlineOption], paymentMethods: [paymentMethodVisa, paymentMethodMaster, paymentMethodAM, offlinePaymentMethod, paymentMethodTicket, paymentMethodTicket2], customOptions: [customerCardOption, accountMoneyOption])
        return paymentMethodSearchMock
    }

    class func getMockPaymentMethods() -> [PaymentMethod] {
        return [self.buildPaymentMethod("amex"), self.buildPaymentMethod("oxxo")]
    }

    class func getMockPaymentTypeIds() -> Set<String> {
        return Set([PaymentTypeId.BITCOIN.rawValue, PaymentTypeId.ACCOUNT_MONEY.rawValue])
    }

    class func buildPaymentType() -> PaymentType {
        let creditCardPaymentTypeId = PaymentTypeId.CREDIT_CARD
        return PaymentType(paymentTypeId: creditCardPaymentTypeId)
    }

    class func buildToken(withESC: Bool = false) -> Token {
        let token = Token(tokenId: "tokenId", publicKey: MLA_PK, cardId: "cardId", luhnValidation: "luhn", status: "status", usedDate: "11", cardNumberLength: 16, creationDate: Date(), lastFourDigits: "1234", firstSixDigit: "123456", securityCodeLength: 3, expirationMonth: 11, expirationYear: 22, lastModifiedDate: Date(), dueDate: Date(), cardHolder: MockBuilder.buildCardholder())
        if withESC {
            token.esc = "esc"
        }
        return token
    }

    class func buildCardToken() -> CardToken {
        let cardToken = CardToken()
        cardToken.cardholder = MockBuilder.buildCardholder()
        return cardToken
    }

    class func buildCardholder() -> Cardholder {
        let cardHolder = Cardholder()
        cardHolder.name = "name"
        cardHolder.identification = Identification()
        return cardHolder
    }

    class func buildCardNumber() -> CardNumber {
        let cardNumber = CardNumber()
        cardNumber.length = 4
        cardNumber.validation = "luhn"
        return cardNumber
    }

    class func buildPXBankDeal() -> PXBankDeal {
        let id_ = "bankDealID"
        let dateExpired = Date()
        let dateStarted = Date()
        let installments = [1,2]
        let issuer = MockBuilder.buildPXIssuer()
        let legals = "Legals Text"
        let picture = MockBuilder.buildPXPicture()
        let maxInstallments = 6
        let paymentMethods = [MockBuilder.buildPXPaymentMethod("idPaymentMethod")]
        let recommendedMessage = "Recommended Message"
        let totalFinancialCost = 86.0

        return PXBankDeal(id: id_, dateExpired: dateExpired, dateStarted: dateStarted, installments: installments, issuer: issuer, legals: legals, picture: picture, maxInstallments: maxInstallments, paymentMethods: paymentMethods, recommendedMessage: recommendedMessage, totalFinancialCost: totalFinancialCost)
    }

    class func buildPXIssuer() -> PXIssuer {
        return PXIssuer(id: "issuer ID", name: "Issuer Name")
    }

    class func buildPXPicture() -> PXPicture {
        return PXPicture(id: "pictureID", size: nil, url: "http://secure.mlstatic.com/openplatform/resources/images/issuers/ico_bank_1078.png", secureUrl: "https://secure.mlstatic.com/openplatform/resources/images/issuers/ico_bank_1078.png")
    }

    class func buildPXBin() -> PXBin {
        return PXBin(exclusionPattern: nil, installmentPattern: "^4", pattern: "^4")
    }

    class func buildPXCardNumber() -> PXCardNumber {
        return PXCardNumber(length: 16, validation: "standard")
    }

    class func buildPXSecurityCode(cvvOnTheBack: Bool = true) -> PXSecurityCode {
        var cardLocation = "back"
        if !cvvOnTheBack {
            cardLocation = "front"
        }
        return PXSecurityCode(cardLocation: cardLocation, mode: "mandatory", length: 3)
    }

    class func buildPXSetting() -> PXSetting {
        let bin = MockBuilder.buildPXBin()
        let cardNumber = MockBuilder.buildPXCardNumber()
        let securityCode = MockBuilder.buildPXSecurityCode()
        return PXSetting(bin: bin, cardNumber: cardNumber, securityCode: securityCode)
    }

    class func buildPXPaymentMethod(_ id: String, name: String? = "", paymentTypeId: String? = "credit_card", multipleSettings: Bool = false) -> PXPaymentMethod {
        let additionalInfoNeeded = ["info"]
        var settings = [MockBuilder.buildPXSetting()]

        if multipleSettings {
            settings = [MockBuilder.buildPXSetting(), MockBuilder.buildPXSetting()]
        }

        return PXPaymentMethod(additionalInfoNeeded: additionalInfoNeeded, id: id, name: name, paymentTypeId: paymentTypeId, status: nil, secureThumbnail: nil, thumbnail: nil, deferredCapture: nil, settings: settings, minAllowedAmount: 0.0, maxAllowedAmount: 2000000, accreditationTime: 1200, merchantAccountId: nil, financialInstitutions: nil)
    }

    class func buildBankDeal() -> BankDeal {
        let promo = BankDeal()
        promo.promoId = "promoId"
        promo.legals = "legals"
        promo.paymentMethods = [MockBuilder.buildPaymentMethod("idPaymentMethod")]
        return promo
    }

    class func buildBinMask() -> BinMask {
        let bin = BinMask()
        bin.pattern = "pattern"
        bin.exclusionPattern = "exclusion_pattern"
        bin.installmentsPattern = "installments_pattern"
        return bin
    }

    class func buildPayerCost(installments: Int = 1, installmentRate: Double = 10, hasCFT: Bool = false) -> PayerCost {
        let payerCost = PayerCost(installments: installments, installmentRate: installmentRate, labels: ["label"], minAllowedAmount: 10, maxAllowedAmount: 100, recommendedMessage: "", installmentAmount: 10, totalAmount: 10)

        if hasCFT {
            payerCost.labels = ["CFT_0,00%|TEA_0,00%"]
        }

        return payerCost
    }

    class func buildIssuer() -> Issuer {
        let issuer = Issuer()
        issuer.issuerId = "id"
        issuer.name = "name"
        return issuer
    }

    class func buildPaymentOptionSelected(_ id: String) -> PaymentMethodOption {
        let option = PaymentMethodSearchItem()
        option.idPaymentMethodSearchItem = id
        option.paymentMethodSearchItemDescription = "description"
        return option
    }

    class func buildCustomerPaymentMethod(_ id: String, paymentMethodId: String) -> CardInformation {
        let customOption = CustomerPaymentMethod()
        customOption.customerPaymentMethodId = id
        customOption.paymentMethodId = paymentMethodId
        customOption.paymentMethodTypeId = paymentMethodId
        return customOption
    }

    class func buildCustomerPaymentMethodWithESC(paymentMethodId: String) -> CardInformation {
        let customOption = CustomerPaymentMethod()
        customOption.customerPaymentMethodId = "esc"
        customOption.paymentMethodId = paymentMethodId
        return customOption
    }

    class func buildPaymentData(paymentMethod: PaymentMethod) -> PaymentData {
        let paymentData = PaymentData()
        paymentData.paymentMethod = paymentMethod
        paymentData.token = MockBuilder.buildToken()
        paymentData.issuer = MockBuilder.buildIssuer()
        paymentData.payerCost = MockBuilder.buildPayerCost()
        return paymentData
    }

    class func buildInstructionsInfo(paymentMethod: PaymentMethod) -> InstructionsInfo {
        let amountInfo = AmountInfo()
        amountInfo.amount = 22.0
        amountInfo.currency = MockBuilder.buildCurrency()
        let intructionsInfo = InstructionsInfo()
        intructionsInfo.amountInfo = amountInfo
        intructionsInfo.instructions = [MockBuilder.buildInstruction()]
        return intructionsInfo
    }

    class func buildCurrency() -> Currency {
        let currency = Currency()
        currency.currencyDescription = "description"
        currency.currencyId = "id"
        currency.decimalPlaces = 1
        currency.decimalSeparator = "."
        return currency
    }

    class func buildInstruction() -> Instruction {
        let instruction = Instruction()
        instruction.references = [MockBuilder.buildInstructionReferenceNumber()]
        instruction.info = ["1. Acesse o seu Internet Banking ou abra o aplicativo do seu banco.", "2. Utilize o código abaixo para realizar o pagamento."]
        instruction.subtitle = "Veja como é fácil pagar o seu produto"
        instruction.secondaryInfo = ["Uma cópia desse boleto foi enviada ao seu e-mail -payer.email- caso você precise realizar o pagamento depois."]
        instruction.accreditationMessage = "Assim que você pagar, será aprovado automaticamente entre 1 e 2 dias úteis, mas considere: Em caso de feriados, será identificado até às 18h do segundo dia útil subsequente ao feriado."
        //instruction.accreditationComment = ["Pagamentos realizados em correspondentes bancários podem ultrapassar este prazo."]
        return instruction
    }

    class func builCompletedInstruction() -> Instruction {
        let instruction = Instruction()
        instruction.references = [MockBuilder.buildInstructionReferenceNumber(), MockBuilder.buildInstructionReference(label: "Concepto", value: ["MPAGO:COMPRA"]), MockBuilder.buildInstructionReference(label: "Empresa", value: ["Mercado Libre - Mercado Pago"])]
        instruction.info = ["Primero sigue estos pasos en el cajero", "", "1. Ingresa a Pagos", "2. Pagos de impuestos y servicios", "3. Rubro cobranzas", "", "Luego te irá pidiendo estos datos"]
        instruction.subtitle = "Paga con estos datos"
        instruction.secondaryInfo = ["También enviamos estos datos a tu email"]
        instruction.tertiaryInfo = ["Si pagas un fin de semana o feriado, será al siguiente día hábil."]
        instruction.accreditationMessage = "Assim que você pagar, será aprovado automaticamente entre 1 e 2 dias úteis, mas considere: Em caso de feriados, será identificado até às 18h do segundo dia útil subsequente ao feriado."
        instruction.accreditationComment = ["Pagamentos realizados em correspondentes bancários podem ultrapassar este prazo."]
        instruction.actions = [MockBuilder.buildInstructionAction()]
        return instruction
    }

    class func buildInstructionReferenceNumber() -> InstructionReference {
        let instructionReference = InstructionReference()
        instructionReference.label = "Número"
        instructionReference.value = ["2379", "1729", "0000", "0400", "1003", "3802", "6025", "4607", "2909", "0063", "3330"]
        instructionReference.separator = " "
        instructionReference.comment = "Você pode copiar e colar o código no fluxo de pagamento do seu aplicativo para torná-lo mais simples e cômodo"
        return instructionReference
    }

    class func buildInstructionReference(label: String, value: [String]) -> InstructionReference {
        let instructionReference = InstructionReference()
        instructionReference.label = label
        instructionReference.value = value
        instructionReference.separator = " "
        instructionReference.comment = ""
        return instructionReference
    }

    class func buildInstructionAction() -> InstructionAction {
        let instructionAction = InstructionAction()
        instructionAction.label = "Ir a banca en línea"
        instructionAction.tag = "link"
        instructionAction.url = "http://www.bancomer.com.mx"
        return instructionAction
    }

    class func buildCompleteInstructionsInfo() -> InstructionsInfo {
        let amountInfo = AmountInfo()
        amountInfo.amount = 22.0
        amountInfo.currency = MockBuilder.buildCurrency()
        let intructionsInfo = InstructionsInfo()
        intructionsInfo.amountInfo = amountInfo
        intructionsInfo.instructions = [MockBuilder.builCompletedInstruction()]
        return intructionsInfo
    }

    class func buildPaymentData(paymentMethodId: String, paymentMethodName: String?, paymentMethodTypeId: String?) -> PaymentData {
        let paymentData = PaymentData()
        paymentData.paymentMethod = MockBuilder.buildPaymentMethod(paymentMethodId, name: paymentMethodName, paymentTypeId: paymentMethodTypeId, multipleSettings: false)
        return paymentData
    }

    class func buildPaymentData(paymentMethodId: String = "visa", installments: Int = 0, installmentRate: Double = 0, withESC: Bool = false) -> PaymentData {
        let paymentData = PaymentData()
        paymentData.paymentMethod = MockBuilder.buildPaymentMethod(paymentMethodId)
        paymentData.issuer = MockBuilder.buildIssuer()
        paymentData.payer = Payer(payerId: "", email: "asd@asd.com", identification: nil, entityType: nil)
        paymentData.payerCost = MockBuilder.buildPayerCost(installments: installments, installmentRate: installmentRate)
        paymentData.token = MockBuilder.buildToken(withESC: withESC)
        return paymentData
    }

    class func buildPayment(_ paymentMethodId: String) -> Payment {
        let payment = Payment()
        payment.paymentMethodId = paymentMethodId
        payment.status = "approved"
        payment.statusDetail = "status_detail"
        let payer = MockBuilder.buildPayer("payerid")
        payment.payer = payer
        return payment
    }

    class func buildPaymentResult(_ status: String? = "status", statusDetail: String = "detail", paymentMethodId: String, paymentTypeId: String = "credit_card") -> PaymentResult {
        let pm = MockBuilder.buildPaymentMethod(paymentMethodId, name: paymentMethodId, paymentTypeId: paymentTypeId)
        let paymentData = MockBuilder.buildPaymentData(paymentMethod: pm)
        let paymentResult = PaymentResult(status: status!, statusDetail: statusDetail, paymentData: paymentData, payerEmail: "email", paymentId: "id", statementDescription: "description")
        return paymentResult
    }

    class func buildInstallment() -> Installment {
        let installment = Installment()
        let payerCost = MockBuilder.buildPayerCost()
        let payerCostNext = MockBuilder.buildPayerCost()
        installment.payerCosts = [payerCost, payerCostNext]
        return installment
    }

    class func buildDiscount() -> DiscountCoupon {
        let discount = DiscountCoupon(discountId: 123)
        discount.amount_off = "20"
        discount.amountWithoutDiscount = 5
        return discount
    }

    class func buildPaymentResult(withESC: Bool = false) -> PaymentResult {
        return PaymentResult(payment: MockBuilder.buildPayment("visa"), paymentData: MockBuilder.buildPaymentData(withESC: withESC))
    }

    class func buildAddress() -> Address {
        let address = Address(streetName: "street_name", streetNumber: 0, zipCode: "zip_code")
        return address
    }

    class func buildCustomer() -> Customer {
        let customer = Customer()
        customer.cards = [MockBuilder.buildCard(paymentMethodId: "visa")]
        customer.defaultCard = "0"
        customer.customerDescription = "description"
        customer.email = "email"
        customer.firstName = "first_name"
        customer.lastName = "last_name"
        customer.customerId = "id"
        customer.identification = buildIdentification()
        customer.liveMode = true
        customer.address = buildAddress()

        return customer
    }

    class func buildApiException(code: String) -> ApiException? {

        if code == ApiUtil.ErrorCauseCodes.INVALID_IDENTIFICATION_NUMBER.rawValue {
            return buildInvalidIdNumberApiException()
        }

        return nil
    }

    class func buildInvalidIdNumberApiException() -> ApiException {
        let apiException = ApiException()
        apiException.message = "Invalid cardholder.identification.number: 312322222 in site_id: MLV"
        apiException.error = "bad_request"
        apiException.status = 400

        var cause = [Cause]()
        let invalidIdCause = Cause()
        invalidIdCause.causeDescription = "Invalid parameter 'cardholder.identification.number'"
        invalidIdCause.code = "324"

        cause.append(invalidIdCause)
        apiException.cause = cause
        return apiException
    }

    class func buildFlowPreferenceWithoutESC() -> FlowPreference {
        let flowPreference = FlowPreference()
        flowPreference.disableESC()
        return flowPreference
    }

}
