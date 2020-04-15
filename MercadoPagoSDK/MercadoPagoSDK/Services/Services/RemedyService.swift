//
//  RemedyService.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 16/03/2020.
//

import Foundation

internal class RemedyService: MercadoPagoService {
    
    let payerAccessToken: String?

    init (baseURL: String, payerAccessToken: String? = nil) {
        self.payerAccessToken = payerAccessToken
        super.init(baseURL: baseURL)
    }

    internal func getRemedy(for paymentMethodId: String, payerPaymentMethodRejected: PXPayerPaymentMethodRejected, alternativePayerPaymentMethods: [PXAlternativePayerPaymentMethod]?, success: @escaping (_ data: Data?) -> Void, failure: ((_ error: PXError) -> Void)?) {
        let params: String = MercadoPagoServices.getParamsAccessToken(payerAccessToken)

        let remedyBody = PXRemedyBody(payerPaymentMethodRejected: payerPaymentMethodRejected, alternativePayerPaymentMethods: alternativePayerPaymentMethods)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let body = try? encoder.encode(remedyBody)

        self.request(uri: PXServicesURLConfigs.MP_REMEDY_URI.replacingOccurrences(of: "${payment_id}", with: paymentMethodId), params: params, body: body, method: HTTPMethod.post, success: success, failure: { _ in
            failure?(PXError(domain: ApiDomain.GET_REMEDY, code: ErrorTypes.NO_INTERNET_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
        })
    }
}
