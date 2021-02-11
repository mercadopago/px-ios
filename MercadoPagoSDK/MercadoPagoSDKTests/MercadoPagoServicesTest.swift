//
//  MercadoPagoServicesTest.swift
//  Pods
//
//  Created by Matheus Leandro Martins on 10/02/21.
//

import XCTest
@testable import MercadoPagoSDKV4

class CustomServiceMock: CustomServices {
    var successResponse = true
    var calledGetPointsAndDiscounts = false
    var calledResetESCCap = false
    var calledCreatePayment = false
    
    func getPointsAndDiscounts(data: Data?, parameters: CustomParametersModel, completion: @escaping (PXPointsAndDiscounts?, Void?) -> Void) {
        calledGetPointsAndDiscounts = true
        successResponse ? completion(PXPointsAndDiscounts(points: nil,
                                                        discounts: nil,
                                                        crossSelling: nil,
                                                        viewReceiptAction: nil,
                                                        topTextBox: nil,
                                                        customOrder: nil,
                                                        expenseSplit: nil,
                                                        paymentMethodsImages: nil,
                                                        primaryButton: nil,
                                                        secondaryButton: nil,
                                                        redirectUrl: nil,
                                                        backUrl: nil,
                                                        autoReturn: nil), nil) : completion(nil, ())
    }
    
    func resetESCCap(cardId: String, privateKey: String?, response: @escaping (Void?, PXError?) -> Void) {
        calledResetESCCap = true
        successResponse ? response((), nil) : response(nil, PXError(domain: "", code: 0))
    }
    
    func createPayment(privateKey: String?, publicKey: String, data: Data?, header: [String : String]?, response: @escaping (PXPayment?, PXError?) -> Void) {
        calledCreatePayment = true
        successResponse ? response(PXPayment(id: 0, status: ""), nil) : response(nil, PXError(domain: "", code: 0))
    }
}

class RemedyServicesMock: RemedyServices {
    var successResponse = true
    var calledGetRemedy = false
    
    func getRemedy(privateKey: String?, oneTap: Bool, payerPaymentMethodRejected: PXPayerPaymentMethodRejected, alternativePayerPaymentMethods: [PXRemedyPaymentMethod]?, completion: @escaping (PXRemedy?, PXError?) -> Void) {
        calledGetRemedy = true
        successResponse ? completion(PXRemedy(), nil) : completion(nil, PXError(domain: "", code: 0))
    }
}

class InstructionsServicesMock: InstructionsServices {
    var successResponse = true
    var calledGetInstructions = false
    
    func getInstructions(paymentId: String, paymentTypeId: String, accessToken: String?, publicKey: String, completion: @escaping (PXInstructions?, PXError?) -> Void) {
        calledGetInstructions = true
        successResponse ? completion(PXInstructions(amountInfo: nil, instructions: []), nil) : completion(nil, PXError(domain: "", code: 0))
    }
}

class GatewayServicesMock: GatewayServices {
    var successResponse = true
    var calledGetToken = false
    var calledCloneToken = false
    var calledValidateToken = false
    
    func getToken(accessToken: String?, publicKey: String, cardTokenJSON: Data?, completion: @escaping (PXToken?, PXError?) -> Void) {
        calledGetToken = true
        successResponse ? completion(PXToken(id: "", publicKey: nil, cardId: "", luhnValidation: nil, status: nil, usedDate: nil, cardNumberLength: 0, dateCreated: nil, securityCodeLength: 0, expirationMonth: 0, expirationYear: 0, dateLastUpdated: nil, dueDate: nil, firstSixDigits: "", lastFourDigits: "", cardholder: nil, esc: nil), nil) : completion(nil, PXError(domain: "", code: 0))
    }
    
    func cloneToken(tokeniD: String, publicKey: String, securityCode: String, completion: @escaping (PXToken?, PXError?) -> Void) {
        calledCloneToken = true
        successResponse ? completion(PXToken(id: "", publicKey: nil, cardId: "", luhnValidation: nil, status: nil, usedDate: nil, cardNumberLength: 0, dateCreated: nil, securityCodeLength: 0, expirationMonth: 0, expirationYear: 0, dateLastUpdated: nil, dueDate: nil, firstSixDigits: "", lastFourDigits: "", cardholder: nil, esc: nil), nil) : completion(nil, PXError(domain: "", code: 0))
    }
    
    func validateToken(tokenId: String, publicKey: String, body: Data, completion: @escaping (PXToken?, PXError?) -> Void) {
        calledValidateToken = true
        successResponse ? completion(PXToken(id: "", publicKey: nil, cardId: "", luhnValidation: nil, status: nil, usedDate: nil, cardNumberLength: 0, dateCreated: nil, securityCodeLength: 0, expirationMonth: 0, expirationYear: 0, dateLastUpdated: nil, dueDate: nil, firstSixDigits: "", lastFourDigits: "", cardholder: nil, esc: nil), nil) : completion(nil, PXError(domain: "", code: 0))
    }
}

class PaymentServicesMock: PaymentServices {
    var successResponse = true
    var calledGetInit = false
    func getInit(preferenceId: String?, privateKey: String?, body: Data?, headers: [String : String]?, completion: @escaping (PXInitDTO?, PXError?) -> Void) {
        calledGetInit = true
        successResponse ? completion(PXInitDTO(preference: nil, oneTap: nil, currency: PXCurrency(id: "", description: nil, symbol: nil, decimalPlaces: nil, decimalSeparator: nil, thousandSeparator: nil), site: PXSite(id: "", currencyId: nil, termsAndConditionsUrl: "", shouldWarnAboutBankInterests: nil), generalCoupon: "", coupons: [:], groups: [], payerPaymentMethods: [], availablePaymentMethods: [], experiments: nil, payerCompliance: nil, configurations: nil, modals: [:]), nil) : completion(nil, PXError(domain: "", code: 0))
    }
}

class MercadoPagoServicesTest: XCTestCase {
    var sut: MercadoPagoServices!
    
    var customService: CustomServiceMock!
    var remedyService: RemedyServicesMock!
    var instructionsService: InstructionsServicesMock!
    var gatewayService: GatewayServicesMock!
    var paymentService: PaymentServicesMock!
    
    
    override func setUp() {
        super.setUp()
        customService = CustomServiceMock()
        remedyService = RemedyServicesMock()
        instructionsService = InstructionsServicesMock()
        gatewayService = GatewayServicesMock()
        paymentService = PaymentServicesMock()
        sut = MercadoPagoServices(publicKey: "Test",
                                  privateKey: "Tests",
                                  customService: customService,
                                  remedyService: remedyService,
                                  instructionsService: instructionsService,
                                  gatewayService: gatewayService,
                                  paymentService: paymentService)
    }
    
    //Has same behavior on success and failure
    func testResetESCCap() {
        var hadCallback = false
        XCTAssertTrue(customService.calledResetESCCap == false)
        sut.resetESCCap(cardId: "") {
            hadCallback = true
        }
        
        XCTAssertTrue(hadCallback == true)
        XCTAssertTrue(customService.calledResetESCCap == true)
    }
    
    func testCreatePaymentSuccess() {
        var hasError = true
        XCTAssertTrue(customService.calledCreatePayment == false)
        sut.createPayment(url: "", uri: "", transactionId: "", paymentDataJSON: Data(), query: nil, headers: nil) { _ in
            hasError = false
        } failure: {  _ in
            hasError = true
        }
        
        XCTAssertTrue(customService.calledCreatePayment == true)
        XCTAssertTrue(hasError == false)
    }
    
    func testCreatePaymentFailure() {
        customService.successResponse = false
        var hasError = false
        XCTAssertTrue(customService.calledCreatePayment == false)
        sut.createPayment(url: "", uri: "", transactionId: "", paymentDataJSON: Data(), query: nil, headers: nil) { _ in
            hasError = false
        } failure: {  _ in
            hasError = true
        }
        
        XCTAssertTrue(customService.calledCreatePayment == true)
        XCTAssertTrue(hasError == true)
    }
    
    func testGetPointsAndDiscountsSuccess() {
        var hasError = true
        XCTAssertTrue(customService.calledGetPointsAndDiscounts == false)
        sut.getPointsAndDiscounts(url: "", uri: "", paymentIds: nil, paymentMethodsIds: nil, campaignId: nil, prefId: nil, platform: "", ifpe: true, merchantOrderId: 0, headers: [:]) { _ in
            hasError = false
        } failure: {
            hasError = true
        }

        XCTAssertTrue(customService.calledGetPointsAndDiscounts == true)
        XCTAssertTrue(hasError == false)
    }
    
    func testGetPointsAndDiscountsFailure() {
        customService.successResponse = false
        var hasError = false
        XCTAssertTrue(customService.calledGetPointsAndDiscounts == false)
        sut.getPointsAndDiscounts(url: "", uri: "", paymentIds: nil, paymentMethodsIds: nil, campaignId: nil, prefId: nil, platform: "", ifpe: true, merchantOrderId: 0, headers: [:]) { _ in
            hasError = false
        } failure: {
            hasError = true
        }

        XCTAssertTrue(customService.calledGetPointsAndDiscounts == true)
        XCTAssertTrue(hasError == true)
    }
    
    func testGetRemedySuccess() {
        var hasError = true
        XCTAssertTrue(remedyService.calledGetRemedy == false)
        sut.getRemedy(for: "", payerPaymentMethodRejected: PXPayerPaymentMethodRejected(customOptionId: nil, paymentMethodId: nil, paymentTypeId: nil, issuerName: nil, lastFourDigit: nil, securityCodeLocation: nil, securityCodeLength: nil, totalAmount: nil, installments: nil, escStatus: nil), alternativePayerPaymentMethods: nil, oneTap: true) { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }

        XCTAssertTrue(remedyService.calledGetRemedy == true)
        XCTAssertTrue(hasError == false)
    }
    
    func testGetRemedyFailure() {
        remedyService.successResponse = false
        var hasError = false
        XCTAssertTrue(remedyService.calledGetRemedy == false)
        sut.getRemedy(for: "", payerPaymentMethodRejected: PXPayerPaymentMethodRejected(customOptionId: nil, paymentMethodId: nil, paymentTypeId: nil, issuerName: nil, lastFourDigit: nil, securityCodeLocation: nil, securityCodeLength: nil, totalAmount: nil, installments: nil, escStatus: nil), alternativePayerPaymentMethods: nil, oneTap: true) { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }

        XCTAssertTrue(remedyService.calledGetRemedy == true)
        XCTAssertTrue(hasError == true)
    }
    
    func testGetInstructionsSuccess() {
        var hasError = true
        XCTAssertTrue(instructionsService.calledGetInstructions == false)
        sut.getInstructions(paymentId: 0, paymentTypeId: "") { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }
        
        XCTAssertTrue(instructionsService.calledGetInstructions == true)
        XCTAssertTrue(hasError == false)
    }
    
    func testGetInstructionsFailure() {
        instructionsService.successResponse = false
        var hasError = true
        XCTAssertTrue(instructionsService.calledGetInstructions == false)
        sut.getInstructions(paymentId: 0, paymentTypeId: "") { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }
        
        XCTAssertTrue(instructionsService.calledGetInstructions == true)
        XCTAssertTrue(hasError == true)
    }
    
    func testCreateTokenSuccess() {
        var hasError = true
        XCTAssertTrue(gatewayService.calledGetToken == false)
        sut.createToken(cardToken: PXCardToken(cardNumber: nil, expirationMonth: 0, expirationYear: 0, securityCode: nil, cardholderName: "", docType: "", docNumber: "")) { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }

        XCTAssertTrue(gatewayService.calledGetToken == true)
        XCTAssertTrue(hasError == false)
    }
    
    func testCreateTokenFailure() {
        gatewayService.successResponse = false
        var hasError = false
        XCTAssertTrue(gatewayService.calledGetToken == false)
        sut.createToken(cardToken: PXCardToken(cardNumber: nil, expirationMonth: 0, expirationYear: 0, securityCode: nil, cardholderName: "", docType: "", docNumber: "")) { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }
        
        XCTAssertTrue(gatewayService.calledGetToken == true)
        XCTAssertTrue(hasError == true)
    }
    
    func testCloneTokenSuccess() {
        var hasError = true
        XCTAssertTrue(gatewayService.calledCloneToken == false)
        sut.cloneToken(tokenId: "", securityCode: "") { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }
        
        XCTAssertTrue(gatewayService.calledCloneToken == true)
        XCTAssertTrue(hasError == false)
    }
    
    func testCloneTokenFailure() {
        gatewayService.successResponse = false
        var hasError = true
        XCTAssertTrue(gatewayService.calledCloneToken == false)
        sut.cloneToken(tokenId: "", securityCode: "") { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }
        
        XCTAssertTrue(gatewayService.calledCloneToken == true)
        XCTAssertTrue(hasError == true)
    }
    
    func testGetOpenPrefInitSearchSuccess() {
        var hasError = true
        XCTAssertTrue(paymentService.calledGetInit == false)
        sut.getOpenPrefInitSearch(pref: PXCheckoutPreference(preferenceId: ""), cardsWithEsc: [], oneTapEnabled: true, splitEnabled: true, discountParamsConfiguration: nil, flow: nil, charges: [], headers: nil) { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }

        
        XCTAssertTrue(paymentService.calledGetInit == true)
        XCTAssertTrue(hasError == false)
    }
    
    func testGetOpenPrefInitSearchFailure() {paymentService.successResponse = false
        var hasError = true
        XCTAssertTrue(paymentService.calledGetInit == false)
        sut.getOpenPrefInitSearch(pref: PXCheckoutPreference(preferenceId: ""), cardsWithEsc: [], oneTapEnabled: true, splitEnabled: true, discountParamsConfiguration: nil, flow: nil, charges: [], headers: nil) { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }
        
        XCTAssertTrue(paymentService.calledGetInit == true)
        XCTAssertTrue(hasError == true)
    }
    
    func testGetClosedPrefInitSearchSuccess() {
        var hasError = true
        XCTAssertTrue(paymentService.calledGetInit == false)
        sut.getClosedPrefInitSearch(preferenceId: "", cardsWithEsc: [], oneTapEnabled: true, splitEnabled: true, discountParamsConfiguration: nil, flow: nil, charges: [], headers: nil) { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }
        
        XCTAssertTrue(paymentService.calledGetInit == true)
        XCTAssertTrue(hasError == false)
    }
    
    func testGetClosedPrefInitSearchFailure() {
        paymentService.successResponse = false
        var hasError = true
        XCTAssertTrue(paymentService.calledGetInit == false)
        sut.getClosedPrefInitSearch(preferenceId: "", cardsWithEsc: [], oneTapEnabled: true, splitEnabled: true, discountParamsConfiguration: nil, flow: nil, charges: [], headers: nil) { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }
        
        XCTAssertTrue(paymentService.calledGetInit == true)
        XCTAssertTrue(hasError == true)
    }
}
