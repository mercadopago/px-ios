//
//  PaymentMethodSearchService.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

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


    internal func getInit(closedPref: Bool, prefId: String?, params: String, bodyJSON: Data?, headers: [String: String]?, success: @escaping (_ paymentMethodSearch: PXInitDTO) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {

        var uri = PXServicesURLConfigs.MP_INIT_URI
        if closedPref, let prefId = prefId {
            uri.append("/")
            uri.append(prefId)
        }

        self.request(uri: uri, params: params, body: bodyJSON, method: HTTPMethod.post, headers:
            headers, cache: false, success: { (data) -> Void in
                do {

                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    if let paymentSearchDic = jsonResult as? NSDictionary {
                        if paymentSearchDic["error"] != nil {
                            let apiException = try PXApiException.fromJSON(data: data)
                            failure(PXError(domain: ApiDomain.GET_PAYMENT_METHODS, code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los métodos de pago"], apiException: apiException))
                        } else {

                            if paymentSearchDic.allKeys.count > 0 {
                                let openPrefInit = try PXInitDTO.fromJSON(data: data)
                                success(openPrefInit)
                            } else {
                                failure(PXError(domain: ApiDomain.GET_PAYMENT_METHODS, code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los métodos de pago"]))
                            }
                        }
                    }
                } catch {
                    failure(PXError(domain: ApiDomain.GET_PAYMENT_METHODS, code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los métodos de pago"]))
                }

        }, failure: { (_) -> Void in
            failure(PXError(domain: ApiDomain.GET_PAYMENT_METHODS, code: ErrorTypes.NO_INTERNET_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
        })
    }



    internal func getOpenPrefInit(pref: PXCheckoutPreference, cardsWithEsc: [String], oneTapEnabled: Bool, splitEnabled: Bool, discountParamsConfiguration: PXDiscountParamsConfiguration?, marketplace: String?, charges: [PXPaymentTypeChargeRule], headers: [String: String]?, success: @escaping (_ paymentMethodSearch: PXInitDTO) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {

        let params = MercadoPagoServices.getParamsAccessToken(payerAccessToken)

        let bodyDiscountsConfiguration = PXDiscountParamsConfiguration(labels: discountParamsConfiguration?.labels ?? [String](), productId: discountParamsConfiguration?.productId ?? "")
        let bodyFeatures = PXInitFeatures(oneTap: oneTapEnabled, split: splitEnabled)
        let body = PXInitBody(preference: pref, publicKey: merchantPublicKey, flow: marketplace, cardsWithESC: cardsWithEsc, charges: charges, discountConfiguration: bodyDiscountsConfiguration, features: bodyFeatures)

        let bodyJSON = try? body.toJSON()

        getInit(closedPref: false, prefId: nil, params: params, bodyJSON: bodyJSON, headers: headers, success: success, failure: failure)
    }

    internal func getClosedPrefInit(preferenceId: String, cardsWithEsc: [String], oneTapEnabled: Bool, splitEnabled: Bool, discountParamsConfiguration: PXDiscountParamsConfiguration?, marketplace: String?, charges: [PXPaymentTypeChargeRule], headers: [String: String]?, success: @escaping (_ paymentMethodSearch: PXInitDTO) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {

        let params = MercadoPagoServices.getParamsAccessToken(payerAccessToken)

        let bodyDiscountsConfiguration = PXDiscountParamsConfiguration(labels: discountParamsConfiguration?.labels ?? [String](), productId: discountParamsConfiguration?.productId ?? "")
        let bodyFeatures = PXInitFeatures(oneTap: oneTapEnabled, split: splitEnabled)
        let body = PXInitBody(preference: nil, publicKey: merchantPublicKey, flow: marketplace, cardsWithESC: cardsWithEsc, charges: charges, discountConfiguration: bodyDiscountsConfiguration, features: bodyFeatures)

        let bodyJSON = try? body.toJSON()

        getInit(closedPref: true, prefId: preferenceId, params: params, bodyJSON: bodyJSON, headers: headers, success: success, failure: failure)
    }
}
