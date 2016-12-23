//
//  IdentificationService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 5/2/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
open class IdentificationService : MercadoPagoService {
    open func getIdentificationTypes(_ method: String = "GET", uri : String = "/identification_types", public_key : String?, success: @escaping (_ jsonResult: AnyObject?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        var params : String? = nil
        if public_key != nil {
            params = "public_key=" + public_key!
        }
        self.request(uri: uri, params: params, body: nil, method: method, success: success, failure: failure)
    }
}
