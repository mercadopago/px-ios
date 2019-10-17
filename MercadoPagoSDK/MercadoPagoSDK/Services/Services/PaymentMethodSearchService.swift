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


    internal func getInit(closedPref: Bool, prefId: String?, params: String, bodyJSON: Data?, success: @escaping (_ paymentMethodSearch: PXOpenPrefInitDTO) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {

        self.baseURL = "https://private-22b696-newinit.apiary-mock.com"

//        var uri = PXServicesURLConfigs.MP_INIT_URI    
        var uri = "/new_init"
        if closedPref, let prefId = prefId {
            uri.append("/")
            uri.append(prefId)
        }

        self.request(uri: uri, params: params, body: bodyJSON, method: HTTPMethod.post, headers:
            nil, cache: false, success: { (data) -> Void in
                do {

                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    if let paymentSearchDic = jsonResult as? NSDictionary {
                        if paymentSearchDic["error"] != nil {
                            let apiException = try PXApiException.fromJSON(data: data)
                            failure(PXError(domain: ApiDomain.GET_PAYMENT_METHODS, code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los métodos de pago"], apiException: apiException))
                        } else {

                            if paymentSearchDic.allKeys.count > 0 {
                                let openPrefInit = try PXOpenPrefInitDTO.fromJSON(data: data)
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



    internal func getOpenPrefInit(pref: PXCheckoutPreference, cardsWithEsc: [String], oneTapEnabled: Bool, splitEnabled: Bool, discountParamsConfiguration: PXDiscountParamsConfiguration?, marketplace: String?, charges: [PXPaymentTypeChargeRule], success: @escaping (_ paymentMethodSearch: PXOpenPrefInitDTO) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {

        let params = MercadoPagoServices.getParamsAccessToken(payerAccessToken)

        let bodyDiscountsConfiguration = PXDiscountParamsConfiguration(labels: discountParamsConfiguration?.labels ?? [String](), productId: discountParamsConfiguration?.productId ?? "")
        let bodyFeatures = PXInitFeatures(oneTap: oneTapEnabled, split: splitEnabled)
        let body = PXInitBody(preference: pref, publicKey: merchantPublicKey, flowId: marketplace, cardsWithESC: cardsWithEsc, charges: charges, discountConfiguration: bodyDiscountsConfiguration, features: bodyFeatures)

        let bodyJSON = try? body.toJSON()

        getInit(closedPref: false, prefId: nil, params: params, bodyJSON: bodyJSON, success: success, failure: failure)
    }

    internal func getInit(pref: PXCheckoutPreference, _ amount: Double, defaultPaymenMethodId: String?, excludedPaymentTypeIds: [String], excludedPaymentMethodIds: [String], cardsWithEsc: [String]?, shouldSkipUserConfirmation: Bool, payer: PXPayer, language: String, expressEnabled: Bool, splitEnabled: Bool, discountParamsConfiguration: PXDiscountParamsConfiguration?, marketplace: String?, charges: [PXPaymentTypeChargeRule]?, success: @escaping (_ paymentMethodSearch: PXPaymentMethodSearch) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {

        var params = MercadoPagoServices.getParamsPublicKey(merchantPublicKey)
        params.paramsAppend(key: ApiParam.PAYER_ACCESS_TOKEN, value: payer.getAccessToken())
        let newExcludedPaymentTypesIds = excludedPaymentTypeIds

        if newExcludedPaymentTypesIds.count > 0 {
            let excludedPaymentTypesParams = newExcludedPaymentTypesIds.map({ $0 }).joined(separator: ",")
            params.paramsAppend(key: ApiParam.EXCLUDED_PAYMET_TYPES, value: String(excludedPaymentTypesParams).trimSpaces())
        }

        if excludedPaymentMethodIds.count > 0 {
            let excludedPaymentMethodsParams = excludedPaymentMethodIds.joined(separator: ",")
            params.paramsAppend(key: ApiParam.EXCLUDED_PAYMENT_METHOD, value: excludedPaymentMethodsParams.trimSpaces())
        }

        if let defaultPaymenMethodId = defaultPaymenMethodId {
            params.paramsAppend(key: ApiParam.DEFAULT_PAYMENT_METHOD, value: defaultPaymenMethodId.trimSpaces())
        }

        let checkoutParams = PXInitCheckoutParams(discountParamsConfiguration: PXDiscountParamsConfiguration(labels: discountParamsConfiguration?.labels ?? [String](), productId: discountParamsConfiguration?.productId ?? ""), cardsWithEsc: cardsWithEsc ?? [String](), charges: charges, supportsSplit: splitEnabled, supportsExpress: expressEnabled, shouldSkipUserConfirmation: shouldSkipUserConfirmation, dynamicDialogLocations: [String](), dynamicViewLocations: [String]())

        var body: PXInitSearchBody
        if let prefId = pref.id {
            body = PXInitSearchBody(preferenceId: prefId, preference: nil, merchantOrderId: nil, checkoutParams: checkoutParams)
        } else {
            body = PXInitSearchBody(preferenceId: nil, preference: pref, merchantOrderId: nil, checkoutParams: checkoutParams)
        }

        let bodyJSON = try? body.toJSON()
        let headers = ["Accept-Language": language]


        self.baseURL = "https://private-22b696-newinit.apiary-mock.com"
//        let uri = PXServicesURLConfigs.MP_INIT_URI
        let uri = "/new_init"

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
                        let paymentSearch = try PXPaymentMethodSearch.fromJSON(data: data)
                        success(paymentSearch)
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

}
