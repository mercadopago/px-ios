//
//  MercadoPagoService.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 8/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class MercadoPagoService: NSObject {

    var baseURL: String!

    init (baseURL: String) {
        super.init()
        self.baseURL = baseURL
    }

    override init () {
        super.init()
    }

    public func request(uri: String, params: String?, body: String?, method: String, headers: [String:String]? = nil, cache: Bool? = true, success: (_ jsonResult: AnyObject?) -> Void,
        failure: ((_ error: NSError) -> Void)?) {


        var finalUri = uri
        if params != nil {
            finalUri = finalUri + "?" + params!
        }

       if method == "POST" {
        }

        do {
            let jsonResponse = try MockManager.getMockResponseFor(finalUri, method: method)

            if jsonResponse != nil {
                success(jsonResponse)
            } else {
                failure!(NSError(domain: uri, code: 400, userInfo: nil))
            }
        } catch {
            failure!(NSError(domain: uri, code: 400, userInfo: nil))
        }
    }
}
