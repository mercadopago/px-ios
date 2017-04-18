//
//  PreferenceService.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 4/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class PreferenceService: MercadoPagoService {
    
    internal func getPreference(_ preferenceId : String, success : @escaping (CheckoutPreference) -> Void, failure : @escaping ((_ error: NSError) -> Void)){
        let params = "public_key=" + MercadoPagoContext.publicKey() + "&api_version=" + ServicePreference.API_VERSION
        self.request(uri: ServicePreference.MP_PREFERENCE_URI + preferenceId, params: params, body: nil, method: "GET", success: { (jsonResult) in
            if let preferenceDic = jsonResult as? NSDictionary {
                if preferenceDic["error"] != nil {
                    failure(NSError(domain: "mercadopago.sdk.PreferenceService.getPreference", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey : "Ha ocurrido un error".localized, NSLocalizedFailureReasonErrorKey : "No se ha podido obtener la preferencia".localized]))
                } else {
                    if preferenceDic.allKeys.count > 0 {
                        let checkoutPreference = CheckoutPreference.fromJSON(preferenceDic)
                        success(checkoutPreference)
                    } else {
                        failure(NSError(domain: "mercadopago.sdk.PreferenceService.getPreference", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey : "Ha ocurrido un error".localized, NSLocalizedFailureReasonErrorKey : "No se ha podido obtener la preferencia".localized]))
                    }
                }
            }
            }, failure : { (error) in
                failure(NSError(domain: "mercadopago.sdk.PreferenceService.getPreference", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey : "Verifique su conexión a internet e intente nuevamente".localized]))
        })
    }
    
}
