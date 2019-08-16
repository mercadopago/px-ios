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

    internal func getInit(pref: PXCheckoutPreference, _ amount: Double, defaultPaymenMethodId: String?, excludedPaymentTypeIds: [String], excludedPaymentMethodIds: [String], cardsWithEsc: [String]?, payer: PXPayer, language: String, expressEnabled: Bool, splitEnabled: Bool, discountParamsConfiguration: PXDiscountParamsConfiguration?, marketplace: String?, charges: [PXPaymentTypeChargeRule]?, success: @escaping (_ paymentMethodSearch: PXPaymentMethodSearch) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {

        var params = MercadoPagoServices.getParamsPublicKey(merchantPublicKey)
        params.paramsAppend(key: ApiParams.PAYER_ACCESS_TOKEN, value: payer.getAccessToken())

        let newExcludedPaymentTypesIds = excludedPaymentTypeIds

        if newExcludedPaymentTypesIds.count > 0 {
            let excludedPaymentTypesParams = newExcludedPaymentTypesIds.map({ $0 }).joined(separator: ",")
            params.paramsAppend(key: ApiParams.EXCLUDED_PAYMET_TYPES, value: String(excludedPaymentTypesParams).trimSpaces())
        }

        if excludedPaymentMethodIds.count > 0 {
            let excludedPaymentMethodsParams = excludedPaymentMethodIds.joined(separator: ",")
            params.paramsAppend(key: ApiParams.EXCLUDED_PAYMENT_METHOD, value: excludedPaymentMethodsParams.trimSpaces())
        }

        if let defaultPaymenMethodId = defaultPaymenMethodId {
            params.paramsAppend(key: ApiParams.DEFAULT_PAYMENT_METHOD, value: defaultPaymenMethodId.trimSpaces())
        }

        let checkoutParams = PXInitCheckoutParams(discountParamsConfiguration: PXDiscountParamsConfiguration(labels: discountParamsConfiguration?.labels ?? [String](), productId: discountParamsConfiguration?.productId ?? ""), cardsWithEsc: cardsWithEsc ?? [String](), charges: charges, supportsSplit: splitEnabled, supportsExpress: expressEnabled, shouldSkipUserConfirmation: false, dynamicDialogLocations: [String](), dynamicViewLocations: [String]())

        var body: PXInitSearchBody
        if let prefId = pref.id {
            body = PXInitSearchBody(preferenceId: prefId, preference: nil, merchantOrderId: nil, checkoutParams: checkoutParams)
        } else {
            body = PXInitSearchBody(preferenceId: nil, preference: pref, merchantOrderId: nil, checkoutParams: checkoutParams)
        }

        let bodyJSON = try? body.toJSON()
        let headers = ["Accept-Language": language]

        self.request(uri: PXServicesURLConfigs.MP_INIT_URI, params: params, body: bodyJSON, method: HTTPMethod.post, headers:
            headers, cache: false, success: { (data) -> Void in
            do {

            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            if let paymentSearchDic = jsonResult as? NSDictionary {
                if paymentSearchDic["error"] != nil {
                    let apiException = try PXApiException.fromJSON(data: data)
                    failure(PXError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los métodos de pago"], apiException: apiException))
                } else {

                    if paymentSearchDic.allKeys.count > 0 {
                        let paymentSearch = try PXPaymentMethodSearch.fromJSON(data: data)
                        success(paymentSearch)
                    } else {
                        failure(PXError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los métodos de pago"]))
                    }
                }
                }
            } catch {
                failure(PXError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los métodos de pago"]))
            }

        }, failure: { (_) -> Void in
            failure(PXError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: ErrorTypes.NO_INTERNET_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
        })
    }

}
