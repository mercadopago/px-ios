//
//  PreferenceService.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 4/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class PreferenceService: MercadoPagoService {
    
    private var MP_PREFERENCE_URI = "/v1/checkout/preferences/"
    
    init(){
        super.init(baseURL: MercadoPagoService.MP_BASE_URL)
    }
    
    internal func getPreference(preferenceId : String, success : (CheckoutPreference) -> Void, failure : ((error: NSError) -> Void)){
        let params = "public_key=" + MercadoPagoContext.publicKey()
        self.request(MP_PREFERENCE_URI + preferenceId, params: params, body: nil, method: "GET", success: { (jsonResult) in
            if let preferenceDic = jsonResult as? NSDictionary {
                if preferenceDic["error"] != nil {
                    failure(error: NSError(domain: "mercadopago.sdk.PreferenceService.getPreference", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey : "Ha ocurrido un error".localized, NSLocalizedFailureReasonErrorKey : "No se han podido obtener la preferencia".localized]))
                } else {
                    if preferenceDic.allKeys.count > 0 {
                        let checkoutPreference = CheckoutPreference.fromJSON(preferenceDic)
                        success(checkoutPreference)
                    } else {
                        failure(error: NSError(domain: "mercadopago.sdk.PreferenceService.getPreference", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey : "Ha ocurrido un error".localized, NSLocalizedFailureReasonErrorKey : "No se ha podido obtener la preferencia".localized]))
                    }
                }
            }
            }, failure : { (error) in
                failure(error: NSError(domain: "mercadopago.sdk.PreferenceService.getPreference", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey : "Verifique su conexión a ineternet e intente nuevamente".localized]))
        })
    }
    
}
