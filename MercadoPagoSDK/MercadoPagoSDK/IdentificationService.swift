//
//  IdentificationService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 5/2/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
open class IdentificationService: MercadoPagoService {
    open func getIdentificationTypes(_ method: String = "GET", uri: String = ServicePreference.MP_IDENTIFICATION_URI, success: @escaping (_ data: Data?) -> Void, failure: ((_ error: NSError) -> Void)?) {

        let params: String = MercadoPagoServices.getParamsPublicKeyAndAcessToken()

        self.request(uri: uri, params: params, body: nil, method: method, success: success, failure: { (error) -> Void in
            if let failure = failure {
                failure(NSError(domain: "mercadopago.sdk.IdentificationService.getIdentificationTypes", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente".localized]))
            }
        })
    }
}
