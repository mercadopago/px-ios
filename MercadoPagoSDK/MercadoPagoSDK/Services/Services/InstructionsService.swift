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

    internal func getInstructions(for paymentId: Int64, paymentTypeId: String? = "", success : @escaping (_ instructionsInfo: PXInstructions) -> Void, failure: ((_ error: PXError) -> Void)?) {
        var params: String = MercadoPagoServices.getParamsPublicKeyAndAcessToken(merchantPublicKey, payerAccessToken)
        params.paramsAppend(key: ApiParam.PAYMENT_TYPE, value: paymentTypeId)
        params.paramsAppend(key: ApiParam.API_VERSION, value: PXServicesURLConfigs.API_VERSION)

        self.request(uri: PXServicesURLConfigs.MP_INSTRUCTIONS_URI.replacingOccurrences(of: "${payment_id}", with: String(paymentId)), params: params, body: nil, method: HTTPMethod.get, cache: false, success: { (data: Data) -> Void in
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary

                let error = jsonResult["error"] as? String
                if error != nil && error!.count > 0 {
                    let apiException = try JSONDecoder().decode(PXApiException.self, from: data) as PXApiException
                    let e : PXError = PXError(domain: ApiDomain.GET_INSTRUCTIONS, code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: [NSLocalizedDescriptionKey: "No se ha podido obtener las intrucciones correspondientes al pago", NSLocalizedFailureReasonErrorKey: jsonResult["error"] as! String], apiException: apiException)
                    failure!(e)
                } else {
                    success(try PXInstructions.fromJSON(data: data))
                }
            } catch {
                failure?(PXError(domain: ApiDomain.GET_INSTRUCTIONS, code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener las instrucciones"]))
            }
        }, failure: { (_) in
            failure?(PXError(domain: ApiDomain.GET_INSTRUCTIONS, code: ErrorTypes.NO_INTERNET_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
        })
    }
}
