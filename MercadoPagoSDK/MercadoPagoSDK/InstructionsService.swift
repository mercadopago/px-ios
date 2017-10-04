//
//  InstructionsService.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 16/2/16.
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

open class InstructionsService: MercadoPagoService {

    @available(*, deprecated: 2.2.4, message: "Use getInstructions(_ paymentId : String, ...) instead. PaymentId can be greater than Int and might fail")
    open func getInstructions(_ paymentId: Int, paymentTypeId: String? = "", success : @escaping (_ instructionsInfo: InstructionsInfo) -> Void, failure: ((_ error: NSError) -> Void)?) {
        let paymentId = String(paymentId)
        self.getInstructions(for: paymentId, paymentTypeId: paymentTypeId, success: success, failure: failure)
    }

    open func getInstructions(for paymentId: String, paymentTypeId: String? = "", success : @escaping (_ instructionsInfo: InstructionsInfo) -> Void, failure: ((_ error: NSError) -> Void)?) {
        var params =  MPServicesBuilder.getParamsPublicKey()

        params.paramsAppend(key: ApiParams.PAYMENT_TYPE, value: paymentTypeId)

        params.paramsAppend(key: ApiParams.API_VERSION, value : ServicePreference.API_VERSION)

        let headers = ["Accept-Language": MercadoPagoContext.getLanguage()]

        self.request(uri: ServicePreference.MP_INSTRUCTIONS_URI.replacingOccurrences(of: "${payment_id}", with: String(paymentId)), params: params, body: nil, method: "GET", headers: headers, cache: false, success: { (jsonResult) -> Void in

            let error = jsonResult?["error"] as? String
            if error != nil && error!.characters.count > 0 {
                let e : NSError = NSError(domain: "com.mercadopago.sdk.getInstructions", code: MercadoPago.ERROR_INSTRUCTIONS, userInfo: [NSLocalizedDescriptionKey: "No se ha podido obtener las intrucciones correspondientes al pago".localized, NSLocalizedFailureReasonErrorKey: jsonResult!["error"] as! String])
                failure!(e)
            } else {
                success(InstructionsInfo.fromJSON(jsonResult as! NSDictionary))
            }
        }, failure: failure)
    }
}
