//
//  InstructionsService.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 16/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

internal class InstructionsService: MercadoPagoService {

    let merchantPublicKey: String!
    let payerAccessToken: String?

    init (baseURL: String, merchantPublicKey: String, payerAccessToken: String? = nil) {
        self.merchantPublicKey = merchantPublicKey
        self.payerAccessToken = payerAccessToken
        super.init(baseURL: baseURL)
    }

    @available(*, deprecated: 2.2.4, message: "Use getInstructions(_ paymentId : String, ...) instead. PaymentId can be greater than Int and might fail")
    internal func getInstructions(_ paymentId: Int, paymentTypeId: String? = "", success : @escaping (_ instructionsInfo: PXInstructions) -> Void, failure: ((_ error: NSError) -> Void)?) {
        let paymentId = Int64(paymentId)
        self.getInstructions(for: paymentId, paymentTypeId: paymentTypeId, language: "es", success: success, failure: failure)
    }

    internal func getInstructions(for paymentId: Int64, paymentTypeId: String? = "", language: String, success : @escaping (_ instructionsInfo: PXInstructions) -> Void, failure: ((_ error: PXError) -> Void)?) {
        var params: String = MercadoPagoServices.getParamsPublicKeyAndAcessToken(merchantPublicKey, payerAccessToken)
        params.paramsAppend(key: ApiParams.PAYMENT_TYPE, value: paymentTypeId)
        params.paramsAppend(key: ApiParams.API_VERSION, value: PXServicesURLConfigs.API_VERSION)

        let headers = ["Accept-Language": language]

        self.request(uri: PXServicesURLConfigs.MP_INSTRUCTIONS_URI.replacingOccurrences(of: "${payment_id}", with: String(paymentId)), params: params, body: nil, method: HTTPMethod.get, headers: headers, cache: false, success: { (data: Data) -> Void in
            do {
                let mockData = data /*"{\"instructions\": [{\"accreditation_message\": \"Após o pagamento, o dinheiro será creditado em 1 ou 2 dias úteis.\",\"info\": null,\"interactions\": [{\"action\": {\"label\": \"Copiar código\",\"tag\": \"copy\",\"url\": \"\",\"content\": \"23794768900000010003380260353974384800633330\"},\"content\": \"23794768900000010003380260353974384800633330\",\"title\": \"Você pode fazer isso pelo Internet Banking com o seu código.\"},{\"action\": {\"label\": \"Ver boleto\",\"tag\": \"link\",\"url\": \"https://www.mercadopago.com/mlb/payments/ticket/helper?payment_id=4242818884&payment_method_reference_id=3539743848&caller_id=347997394&hash=636aeeb4-d524-4b56-b0c4-4087aec60909\"},\"content\": \"\",\"title\": \"Ou imprimir o boleto para pagá-lo em uma agência bancária.\"}],\"references\": [],\"secondary_info\": [\"Enviamos o boleto por e-mail para que você o tenha disponível quando precisar. \"],\"title\": \"Pronto, pague o seu boleto de R$ 10,00 \",\"type\": \"ticket\"}]}".data(using: .utf8)*/
                let jsonResult = try JSONSerialization.jsonObject(with: mockData, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary

                let error = jsonResult["error"] as? String
                if error != nil && error!.count > 0 {
                    let apiException = try PXApiException.fromJSON(data: mockData)
                    let e : PXError = PXError(domain: "com.mercadopago.sdk.getInstructions", code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: [NSLocalizedDescriptionKey: "No se ha podido obtener las intrucciones correspondientes al pago", NSLocalizedFailureReasonErrorKey: jsonResult["error"] as! String], apiException: apiException)
                    failure!(e)
                } else {
                    success(try PXInstructions.fromJSON(data: mockData))
                }
            } catch {
                failure?(PXError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener las instrucciones"]))
            }
        }, failure: { (error) in
            failure?(PXError(domain: "com.mercadopago.sdk.getInstructions", code: ErrorTypes.NO_INTERNET_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
        })
    }
}
