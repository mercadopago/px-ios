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

    internal func getPaymentMethods(_ amount: Double, customerEmail: String? = nil, customerId: String? = nil, defaultPaymenMethodId: String?, excludedPaymentTypeIds: [String], excludedPaymentMethodIds: [String], cardsWithEsc: [String]?, supportedPlugins: [String]?, site: PXSite, payer: PXPayer, language: String, differentialPricingId: String?, defaultInstallments: String?, expressEnabled: String, splitEnabled: String, discountParamsConfiguration: PXDiscountParamsConfiguration?, marketplace: String?, charges: [PXPaymentTypeChargeRule]?, maxInstallments: String?, success: @escaping (_ paymentMethodSearch: PXPaymentMethodSearch) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {

        var params = MercadoPagoServices.getParamsPublicKey(merchantPublicKey)
        let roundedAmount = PXAmountHelper.getRoundedAmountAsNsDecimalNumber(amount: amount)

        params.paramsAppend(key: ApiParam.AMOUNT, value: roundedAmount.stringValue)

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

        if let customDefaultInstallments = defaultInstallments {
            params.paramsAppend(key: ApiParam.DEFAULT_INSTALLMENTS, value: customDefaultInstallments)
        }

        if let customMaxInstallments = maxInstallments {
            params.paramsAppend(key: ApiParam.MAX_INSTALLMENTS, value: customMaxInstallments)
        }

        params.paramsAppend(key: ApiParam.EMAIL, value: customerEmail)
        params.paramsAppend(key: ApiParam.CUSTOMER_ID, value: customerId)
        params.paramsAppend(key: ApiParam.SITE_ID, value: site.id)
        params.paramsAppend(key: ApiParam.API_VERSION, value: PXServicesURLConfigs.API_VERSION)
        params.paramsAppend(key: ApiParam.DIFFERENTIAL_PRICING_ID, value: differentialPricingId)

        if let cardsWithEscParams = cardsWithEsc?.map({ $0 }).joined(separator: ",") {
            params.paramsAppend(key: "cards_esc", value: cardsWithEscParams)
        }

        if let supportedPluginsParams = supportedPlugins?.map({ $0 }).joined(separator: ",") {
            params.paramsAppend(key: "support_plugins", value: supportedPluginsParams)
        }

        params.paramsAppend(key: "express_enabled", value: expressEnabled)

        params.paramsAppend(key: "split_payment_enabled", value: splitEnabled)

        let body = PXPaymentMethodSearchBody(privateKey: payer.accessToken, email: payer.email, marketplace: marketplace, productId: discountParamsConfiguration?.productId, labels: discountParamsConfiguration?.labels, charges: charges, processingModes: processingModes, branchId: branchId)
        let bodyJSON = try? body.toJSON()

        let headers = ["Accept-Language": language]

        self.request(uri: PXServicesURLConfigs.MP_SEARCH_PAYMENTS_URI, params: params, body: bodyJSON, method: HTTPMethod.post, headers: headers, cache: false, success: { (data) -> Void in
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
