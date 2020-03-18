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

    internal func getRemedy(for paymentMethodId: String, payerPaymentMethodRejected: PXPayerPaymentMethodRejected, success: @escaping (_ data: Data?) -> Void, failure: ((_ error: PXError) -> Void)?) {
        let params: String = MercadoPagoServices.getParamsAccessToken(payerAccessToken)
        
        let alternativePayerPaymentMethods = [
        PXAlternativePayerPaymentMethod(paymentMethodId: "visa",
                                        paymentTypeId: "credit_card",
                                        installments: [
                                            PXPaymentMethodInstallment(installments: 2,
                                                                       totalAmount: 123.00,
                                                                       labels: ["CFT: 0%"],
                                                                       recommendedMessage: "xxx"),
                                            PXPaymentMethodInstallment(installments: 2,
                                                                       totalAmount: 190.00,
                                                                       labels: ["CFT: 50%"],
                                                                       recommendedMessage: "aaa")],
                                        selectedPayerCostIndex: 1,
                                        esc: true),
                                        PXAlternativePayerPaymentMethod(paymentMethodId: "master",
                                                                          paymentTypeId: "credit_card",
                                                                          installments: [
                                                                            PXPaymentMethodInstallment(installments: 1,
                                                                                                       totalAmount: 150.00,
                                                                                                       labels: ["CFT: 50%"],
                                                                                                       recommendedMessage: "bbb"),
                                                                            PXPaymentMethodInstallment(installments: 2,
                                                                                                       totalAmount: 140.00,
                                                                                                       labels: ["CFT: 10%"],
                                                                                                       recommendedMessage: "mmm")],
                                                                          selectedPayerCostIndex: 0,
                                                                          esc: false)]

        let remedyBody = PXRemedyBody(payerPaymentMethodRejected: payerPaymentMethodRejected, alternativePayerPaymentMethods: alternativePayerPaymentMethods)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let body = try? encoder.encode(remedyBody)

        self.request(uri: PXServicesURLConfigs.MP_REMEDY_URI.replacingOccurrences(of: "${payment_id}", with: paymentMethodId), params: params, body: body, method: HTTPMethod.post, success: success, failure: { _ in
            failure?(PXError(domain: ApiDomain.GET_REMEDY, code: ErrorTypes.NO_INTERNET_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
        })
    }
}
