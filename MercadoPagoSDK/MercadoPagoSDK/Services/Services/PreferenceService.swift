//
//  PreferenceService.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 4/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

internal class PreferenceService: MercadoPagoService {
    
    internal func getPreference(publicKey: String, preferenceId: String, success : @escaping (PXCheckoutPreference) -> Void, failure : @escaping ((_ apiException: PXError) -> Void)) {
        let params = "public_key=" + publicKey + "&api_version=" + PXServicesURLConfigs.API_VERSION
        self.request(uri: PXServicesURLConfigs.MP_PREFERENCE_URI + preferenceId, params: params, body: nil, method: HTTPMethod.get, success: { (data: Data) in
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                if let preferenceDic = jsonResult as? NSDictionary {
                    if preferenceDic["error"] != nil {
                        let apiException = try PXApiException.fromJSON(data: data)
                        failure(PXError(domain: ApiDomain.GET_PREFERENCE, code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener la preferencia"], apiException: apiException))
                    } else {
                        if preferenceDic.allKeys.count > 0 {
                            let checkoutPreference = try PXCheckoutPreference.fromJSON(data: data)
                            success(checkoutPreference)
                        } else {
                            failure(PXError(domain: ApiDomain.GET_PREFERENCE, code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener la preferencia"]))
                        }
                    }
                } } catch {
                    failure(PXError(domain: ApiDomain.GET_PREFERENCE, code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener la preferencia"]))
            }
        }, failure: { (_) in
            failure(PXError(domain: ApiDomain.GET_PREFERENCE, code: ErrorTypes.NO_INTERNET_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
        })
    }

}
