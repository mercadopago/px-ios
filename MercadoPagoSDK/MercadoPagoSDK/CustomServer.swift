//
//  CustomServer.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class CustomServer: NSObject {

    open class func createPayment(url: String, uri: String, paymentData: NSDictionary, query: NSDictionary?, success: @escaping (_ payment: Payment) -> Void, failure: ((_ error: NSError) -> Void)?) {
        let service: CustomService = CustomService(baseURL: url, URI: uri)

        var queryString = ""
        if let q = query, !NSDictionary.isNullOrEmpty(query) {
            queryString = q.toJsonString()
        }

        var body = ""
        if !NSDictionary.isNullOrEmpty(paymentData) {
            body = Utils.append(firstJSON: paymentData.toJsonString(), secondJSON: queryString)
        }

        service.createPayment(body: body, success: success, failure: failure)
    }
}
