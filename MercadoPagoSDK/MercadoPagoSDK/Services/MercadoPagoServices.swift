//
//  MercadoPagoServices.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
// Se importa MLCardForm para reutilizar la clase de Reachability
import MLCardForm

internal class MercadoPagoServices: NSObject {
    // MARK: - Private properties
    private var processingModes: [String] = PXServicesURLConfigs.MP_DEFAULT_PROCESSING_MODES
    private var branchId: String?
    private var baseURL: String! = PXServicesURLConfigs.MP_API_BASE_URL
    private var gatewayBaseURL: String!
    private var language: String = NSLocale.preferredLanguages[0]
    
    private let customService: CustomServices
    private let remedyService: RemedyServices
    private let instructionsService: InstructionsServices
    private let gatewayService: GatewayServices
    private let paymentService: PaymentServices
    
    // MARK: - Internal properties
    var reachability: Reachability?
    var hasInternet: Bool = true
    
    // MARK: - Open perperties
    open var publicKey: String
    open var privateKey: String?

    // MARK: - Initialization
    init(publicKey: String,
         privateKey: String? = nil,
         customService: CustomServices = CustomServicesImpl(),
         remedyService: RemedyServices = RemedyServicesImpl(),
         instructionsService: InstructionsServices = InstructionsServicesImpl(),
         gatewayService: GatewayServices = GatewayServicesImpl(),
         paymentService: PaymentServices = PaymentServicesImpl()) {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.customService = customService
        self.remedyService = remedyService
        self.gatewayService = gatewayService
        self.instructionsService = instructionsService
        self.paymentService = paymentService
        super.init()
        addReachabilityObserver()
    }

    deinit {
        removeReachabilityObserver()
    }

    func update(processingModes: [String]? , branchId: String? = nil) {
        self.processingModes = processingModes ?? PXServicesURLConfigs.MP_DEFAULT_PROCESSING_MODES
        self.branchId = branchId
    }

    func getTimeOut() -> TimeInterval {
        return 15.0
    }

    func resetESCCap(cardId: String, onCompletion : @escaping () -> Void) {
        customService.resetESCCap(cardId: cardId, privateKey: privateKey) { _, _ in
            onCompletion()
        }
    }

    func getInstructions(paymentId: Int64, paymentTypeId: String, callback : @escaping (PXInstructions) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        instructionsService.getInstructions(paymentId: String(paymentId), paymentTypeId: paymentTypeId, accessToken: privateKey, publicKey: publicKey) { instructions, error in
            if let instructions = instructions {
                callback(instructions)
            } else if let error = error {
                failure(error)
            }
        }
        
        
//        let instructionsService = InstructionsService(baseURL: baseURL, merchantPublicKey: publicKey, payerAccessToken: privateKey)
//        instructionsService.getInstructions(for: paymentId, paymentTypeId: paymentTypeId, success: { (instructionsInfo : PXInstructions) -> Void in
//            callback(instructionsInfo)
//        }, failure: failure)
    }

    func getOpenPrefInitSearch(pref: PXCheckoutPreference, cardsWithEsc: [String], oneTapEnabled: Bool, splitEnabled: Bool, discountParamsConfiguration: PXDiscountParamsConfiguration?, flow: String?, charges: [PXPaymentTypeChargeRule], headers: [String: String]?, callback : @escaping (PXInitDTO) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        
        
        let bodyFeatures = PXInitFeatures(oneTap: oneTapEnabled, split: splitEnabled)
        let body = PXInitBody(preference: pref, publicKey: publicKey, flow: flow, cardsWithESC: cardsWithEsc, charges: charges, discountConfiguration: discountParamsConfiguration, features: bodyFeatures)

        let bodyJSON = try? body.toJSON()
        
        paymentService.getInit(preferenceId: nil, privateKey: privateKey, body: bodyJSON, headers: headers) { dto, error in
            if let dto = dto {
                callback(dto)
            } else if let error = error {
                failure(error)
            }
        }
        
//        let paymentMethodSearchService = PaymentMethodSearchService(baseURL: baseURL, merchantPublicKey: publicKey, payerAccessToken: privateKey, processingModes: processingModes, branchId: branchId)
//
//        paymentMethodSearchService.getOpenPrefInit(pref: pref, cardsWithEsc: cardsWithEsc, oneTapEnabled: oneTapEnabled, splitEnabled: splitEnabled, discountParamsConfiguration: discountParamsConfiguration, flow: flow, charges: charges, headers: headers, success: callback, failure: failure)
    }

    func getClosedPrefInitSearch(preferenceId: String, cardsWithEsc: [String], oneTapEnabled: Bool, splitEnabled: Bool, discountParamsConfiguration: PXDiscountParamsConfiguration?, flow: String?, charges: [PXPaymentTypeChargeRule], headers: [String: String]?, callback : @escaping (PXInitDTO) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let bodyFeatures = PXInitFeatures(oneTap: oneTapEnabled, split: splitEnabled)
        let body = PXInitBody(preference: nil, publicKey: publicKey, flow: flow, cardsWithESC: cardsWithEsc, charges: charges, discountConfiguration: discountParamsConfiguration, features: bodyFeatures)

        let bodyJSON = try? body.toJSON()

        paymentService.getInit(preferenceId: preferenceId, privateKey: privateKey, body: bodyJSON, headers: headers) { dto, error in
            if let dto = dto {
                callback(dto)
            } else if let error = error {
                failure(error)
            }
        }
    }

    func createPayment(url: String, uri: String, transactionId: String? = nil, paymentDataJSON: Data, query: [String: String]? = nil, headers: [String: String]? = nil, callback : @escaping (PXPayment) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        
        customService.createPayment(privateKey: privateKey, publicKey: publicKey, data: paymentDataJSON, header: headers) { payment, error in
            if let payment = payment {
                callback(payment)
            } else if let error = error {
                failure(error)
            }
        }
        
        
//        let service: CustomService = CustomService(baseURL: url, URI: uri)
//
//
//        var params = MercadoPagoServices.getParamsPublicKeyAndAcessToken(publicKey, privateKey)
//        params.paramsAppend(key: ApiParam.API_VERSION, value: PXServicesURLConfigs.API_VERSION)
//        if let queryParams = query as NSDictionary? {
//            params = queryParams.parseToQuery()
//        }
//
//        service.createPayment(headers: headers, body: paymentDataJSON, params: params, success: callback, failure: failure)
    }

    func getPointsAndDiscounts(url: String, uri: String, paymentIds: [String]? = nil, paymentMethodsIds: [String]? = nil, campaignId: String?, prefId: String?, platform: String, ifpe: Bool, merchantOrderId: Int?, headers: [String: String], callback : @escaping (PXPointsAndDiscounts) -> Void, failure: @escaping (() -> Void)) {
        let parameters = CustomParametersModel(paymentMethodIds: getPaymentMethodsIds(paymentMethodsIds),
                                               paymentiDS: getPaymentIds(paymentIds),
                                               ifpe: String(ifpe),
                                               prefId: prefId,
                                               campaignId: campaignId,
                                               flowName: MPXTracker.sharedInstance.getFlowName(),
                                               merchantOrderId: merchantOrderId != nil ? String(merchantOrderId!) : nil)
        customService.getPointsAndDiscounts(data: nil, parameters: parameters) { pointsAndDiscounts, error in
            if let pointsAndDiscounts = pointsAndDiscounts {
                callback(pointsAndDiscounts)
            } else if let _ = error {
                failure()
            }
        }
        
        
        
        
        
        
//
//        let service: CustomService = CustomService(baseURL: url, URI: uri)
//
//        var params = MercadoPagoServices.getParamsAccessTokenAndPaymentIdsAndPlatform(privateKey, paymentIds, platform)
//        params.paramsAppend(key: ApiParam.PAYMENT_METHODS_IDS, value: getPaymentMethodsIds(paymentMethodsIds))
//
//        params.paramsAppend(key: ApiParam.API_VERSION, value: PXServicesURLConfigs.API_VERSION)
//        params.paramsAppend(key: ApiParam.IFPE, value: String(ifpe))
//        params.paramsAppend(key: ApiParam.PREF_ID, value: prefId)
//
//        if let campaignId = campaignId {
//            params.paramsAppend(key: ApiParam.CAMPAIGN_ID, value: campaignId)
//        }
//
//        if let flowName = MPXTracker.sharedInstance.getFlowName() {
//            params.paramsAppend(key: ApiParam.FLOW_NAME, value: flowName)
//        }
//
//        if let merchantOrderId = merchantOrderId {
//            params.paramsAppend(key: ApiParam.MERCHANT_ORDER_ID, value: String(merchantOrderId))
//        }
//
//        service.getPointsAndDiscounts(headers: headers, body: nil, params: params, success: callback, failure: failure)
    }

    func createToken(cardToken: PXCardToken, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        createToken(cardToken: try? cardToken.toJSON(), callback: callback, failure: failure)
    }

    func createToken(savedESCCardToken: PXSavedESCCardToken, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        createToken(cardToken: try? savedESCCardToken.toJSON(), callback: callback, failure: failure)
    }

    func createToken(savedCardToken: PXSavedCardToken, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        createToken(cardToken: try? savedCardToken.toJSON(), callback: callback, failure: failure)
    }

    func createToken(cardToken: Data?, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        
        gatewayService.getToken(accessToken: privateKey, publicKey: publicKey, cardTokenJSON: cardToken) { token, error in
            if let token = token {
                callback(token)
            } else if let error = error {
                failure(error)
            }
        }
    }

    func cloneToken(tokenId: String, securityCode: String, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        gatewayService.cloneToken(tokeniD: tokenId, publicKey: publicKey, securityCode: securityCode) { token, error in
            if let token = token {
                callback(token)
            } else if let error = error {
                failure(error)
            }
        }
        
        
        
        
        
        
//        let service: GatewayService = GatewayService(baseURL: getGatewayURL(), merchantPublicKey: publicKey, payerAccessToken: privateKey)
//        service.cloneToken(public_key: publicKey, tokenId: tokenId, securityCode: securityCode, success: {(data: Data) -> Void in
//            do {
//                let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
//                var token : PXToken
//                if let tokenDic = jsonResult as? NSDictionary {
//                    if tokenDic["error"] == nil {
//                        token = try JSONDecoder().decode(PXToken.self, from: data) as PXToken
//                        callback(token)
//                    } else {
//                        let apiException = try JSONDecoder().decode(PXApiException.self, from: data) as PXApiException
//                        failure(PXError(domain: ApiDomain.CLONE_TOKEN, code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: tokenDic as? [String: Any], apiException: apiException))
//                    }
//                }
//            } catch {
//                failure(PXError(domain: ApiDomain.CLONE_TOKEN, code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido clonar el token"]))
//            }
//        }, failure: failure)
    }
    
    func getRemedy(for paymentMethodId: String, payerPaymentMethodRejected: PXPayerPaymentMethodRejected, alternativePayerPaymentMethods: [PXRemedyPaymentMethod]?, oneTap: Bool, success : @escaping (PXRemedy) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        
        remedyService.getRemedy(privateKey: privateKey, oneTap: oneTap, payerPaymentMethodRejected: payerPaymentMethodRejected, alternativePayerPaymentMethods: alternativePayerPaymentMethods) { remedy, error in
            if let remedy = remedy {
                success(remedy)
            } else if let error = error {
                failure(error)
            }
        }
        
//        let service = RemedyService(baseURL: baseURL, payerAccessToken: privateKey)

//        service.getRemedy(for: paymentMethodId, payerPaymentMethodRejected: payerPaymentMethodRejected, alternativePayerPaymentMethods: alternativePayerPaymentMethods, oneTap: oneTap, success: { data -> Void in
//            guard let data = data else {
//                failure(PXError(domain: ApiDomain.GET_REMEDY, code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener el remedy"]))
//                return
//            }
//            do {
//                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//                let responseObject = try decoder.decode(PXRemedy.self, from: data)
//                success(responseObject)
//            } catch {
//                failure(PXError(domain: ApiDomain.GET_REMEDY, code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener el remedy"]))
//            }
//        }, failure: failure)
    }

    //SETS
    func setBaseURL(_ baseURL: String) {
        self.baseURL = baseURL
    }

    func setGatewayBaseURL(_ gatewayBaseURL: String) {
        self.gatewayBaseURL = gatewayBaseURL
    }

    func getGatewayURL() -> String {
        if !String.isNullOrEmpty(gatewayBaseURL) {
            return gatewayBaseURL
        }
        return baseURL
    }

    class func getParamsPublicKey(_ merchantPublicKey: String) -> String {
        var params: String = ""
        params.paramsAppend(key: ApiParam.PUBLIC_KEY, value: merchantPublicKey)
        return params
    }

    class func getParamsAccessToken(_ payerAccessToken: String?) -> String {
        var params: String = ""
        params.paramsAppend(key: ApiParam.PAYER_ACCESS_TOKEN, value: payerAccessToken)
        return params
    }

    class func getParamsPublicKeyAndAcessToken(_ merchantPublicKey: String, _ payerAccessToken: String?) -> String {
        var params: String = ""

        if !String.isNullOrEmpty(payerAccessToken) {
            params.paramsAppend(key: ApiParam.PAYER_ACCESS_TOKEN, value: payerAccessToken!)
        }
        params.paramsAppend(key: ApiParam.PUBLIC_KEY, value: merchantPublicKey)

        return params
    }

    func getPaymentIds(_ paymentIds: [String]?) -> String {
        var params: String = ""

        if let paymentIds = paymentIds, !paymentIds.isEmpty {
            var paymentIdsString = ""
            for (index, paymentId) in paymentIds.enumerated() {
                if index != 0 {
                    paymentIdsString.append(",")
                }
                paymentIdsString.append(paymentId)
            }
            params.paramsAppend(key: ApiParam.PAYMENT_IDS, value: paymentIdsString)
        }
        
        return params
    }

    func getPaymentMethodsIds(_ paymentMethodsIds: [String]?) -> String {
        var paymentMethodsIdsString = ""
        if let paymentMethodsIds = paymentMethodsIds {
            for (index, paymentMethodId) in paymentMethodsIds.enumerated() {
                if index != 0 {
                    paymentMethodsIdsString.append(",")
                }
                if paymentMethodId.isNotEmpty {
                    paymentMethodsIdsString.append(paymentMethodId)
                }
            }
        }
        return paymentMethodsIdsString
    }

    func setLanguage(language: String) {
        self.language = language
    }
}
