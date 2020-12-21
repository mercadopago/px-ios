//
//  PaymentMethodSearchService.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

internal class PaymentMethodSearchService: MercadoPagoService {

    let merchantPublicKey: String
    let payerAccessToken: String?
    let processingModes: [String]
    let branchId: String?

    init(baseURL: String, merchantPublicKey: String, payerAccessToken: String? = nil, processingModes: [String], branchId: String?) {
        self.merchantPublicKey = merchantPublicKey
        self.payerAccessToken = payerAccessToken
        self.processingModes = processingModes
        self.branchId = branchId
        super.init(baseURL: baseURL)
    }

    private func getInit(prefId: String?, bodyJSON: Data?, headers: [String: String]?, success: @escaping (_ paymentMethodSearch: PXInitDTO) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {

        var uri = PXServicesURLConfigs.MP_INIT_URI
        if let prefId = prefId {
            uri.append("/\(prefId)")
        }
        
        let params = MercadoPagoServices.getParamsAccessToken(payerAccessToken)

        self.request(uri: uri, params: params, body: bodyJSON, method: HTTPMethod.post, headers:
            headers, cache: false, success: { (data) -> Void in
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    if let paymentSearchDic = jsonResult as? NSDictionary {
                        if paymentSearchDic["error"] != nil {
                            let apiException = try JSONDecoder().decode(PXApiException.self, from: data) as PXApiException
                            failure(PaymentMethodSearchService.getError(code: ErrorTypes.API_EXCEPTION_ERROR, apiException: apiException))
                        } else {
                            if paymentSearchDic.allKeys.count > 0 {
                                let initDTO = try JSONDecoder().decode(PXInitDTO.self, from: data) as PXInitDTO
                                success(initDTO)
                            } else {
                                failure(PaymentMethodSearchService.getError())
                            }
                        }
                    }
                } catch {
                    printDebug("PaymentMethodSearchService getInit error: \(error).")
                    failure(PaymentMethodSearchService.getError())
                }

        }, failure: { (_) -> Void in
            failure(PaymentMethodSearchService.getError(code: ErrorTypes.NO_INTERNET_ERROR, reason: "Verifique su conexión a internet e intente nuevamente"))
        })
    }
    
    private static func getError(code: Int = ErrorTypes.API_UNKNOWN_ERROR,
                                 reason: String = "No se ha podido obtener los métodos de pago",
                                 apiException: PXApiException? = nil) -> PXError {
        return PXError(domain: ApiDomain.GET_PAYMENT_METHODS, code: code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: reason], apiException: apiException)
    }

    internal func getOpenPrefInit(pref: PXCheckoutPreference, cardsWithEsc: [String], oneTapEnabled: Bool, splitEnabled: Bool, discountParamsConfiguration: PXDiscountParamsConfiguration?, flow: String?, charges: [PXPaymentTypeChargeRule], headers: [String: String]?, success: @escaping (_ paymentMethodSearch: PXInitDTO) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {

        let bodyFeatures = PXInitFeatures(oneTap: oneTapEnabled, split: splitEnabled)
        let body = PXInitBody(preference: pref, publicKey: merchantPublicKey, flow: flow, cardsWithESC: cardsWithEsc, charges: charges, discountConfiguration: discountParamsConfiguration, features: bodyFeatures)

        let bodyJSON = try? body.toJSON()

        getInit(prefId: nil, bodyJSON: bodyJSON, headers: headers, success: success, failure: failure)
    }

    internal func getClosedPrefInit(preferenceId: String, cardsWithEsc: [String], oneTapEnabled: Bool, splitEnabled: Bool, discountParamsConfiguration: PXDiscountParamsConfiguration?, flow: String?, charges: [PXPaymentTypeChargeRule], headers: [String: String]?, success: @escaping (_ paymentMethodSearch: PXInitDTO) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {

        let bodyFeatures = PXInitFeatures(oneTap: oneTapEnabled, split: splitEnabled)
        let body = PXInitBody(preference: nil, publicKey: merchantPublicKey, flow: flow, cardsWithESC: cardsWithEsc, charges: charges, discountConfiguration: discountParamsConfiguration, features: bodyFeatures)

        let bodyJSON = try? body.toJSON()

        getInit(prefId: preferenceId, bodyJSON: bodyJSON, headers: headers, success: success, failure: failure)
    }
}
