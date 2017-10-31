//
//  MercadoPagoService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 5/2/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

open class MercadoPagoService: NSObject {

    let MP_DEFAULT_TIME_OUT = 15.0
    
    open static var MP_TEST_ENV = "/beta"
    open static var MP_PROD_ENV = "/v1"
    open static var MP_SELECTED_ENV = MP_PROD_ENV

    open static var API_VERSION = "1.4.X"
    open static let MP_API_BASE_URL_PROD: String =  "https://api.mercadopago.com"
    open static let MP_API_BASE_URL: String =  MP_API_BASE_URL_PROD

    open static var MP_ENVIROMENT = MP_SELECTED_ENV  + "/checkout"
    open static let MP_OP_ENVIROMENT = "/v1"
    open static let PAYMENT_METHODS = "/payment_methods"
    open static let INSTALLMENTS = "\(PAYMENT_METHODS)/installments"
    open static let CARD_TOKEN = "/card_tokens"
    open static let CARD_ISSSUERS = "\(PAYMENT_METHODS)/card_issuers"
    open static let PAYMENTS = "/payments"
    open static let MP_CREATE_TOKEN_URI = MP_OP_ENVIROMENT + CARD_TOKEN
    open static let MP_PAYMENT_METHODS_URI = MP_OP_ENVIROMENT + PAYMENT_METHODS
    open static var MP_INSTALLMENTS_URI = MP_OP_ENVIROMENT + INSTALLMENTS
    open static var MP_ISSUERS_URI = MP_OP_ENVIROMENT + CARD_ISSSUERS
    open static let MP_IDENTIFICATION_URI = "/identification_types"
    open static let MP_PROMOS_URI = MP_OP_ENVIROMENT + PAYMENT_METHODS + "/deals"
    open static let MP_SEARCH_PAYMENTS_URI = MP_ENVIROMENT + PAYMENT_METHODS + "/search/options"
    open static let MP_INSTRUCTIONS_URI = MP_ENVIROMENT + PAYMENTS + "/${payment_id}/results"
    open static let MP_PREFERENCE_URI = MP_ENVIROMENT + "/preferences/"
    open static let MP_DISCOUNT_URI =  "/discount_campaigns/"
    open static let MP_CUSTOMER_URI = "/customers?preference_id="
    open static let MP_PAYMENTS_URI = MP_ENVIROMENT + PAYMENTS

    var baseURL: String!
    init (baseURL: String) {
        super.init()
        self.baseURL = baseURL
    }
    override init () {
        super.init()
    }

    public func request(uri: String, params: String?, body: String?, method: String, headers: [String:String]? = nil, cache: Bool = true, success: @escaping (_ data: Data) -> Void,
                        failure: ((_ error: NSError) -> Void)?) {
        var url = baseURL + uri
        var requesturl = url
        if !String.isNullOrEmpty(params) {
            requesturl += "?" + params!
        }

        let finalURL: NSURL = NSURL(string: requesturl)!
        let request: NSMutableURLRequest
        if cache {
            request  = NSMutableURLRequest(url: finalURL as URL,
                                           cachePolicy: .returnCacheDataElseLoad, timeoutInterval: MP_DEFAULT_TIME_OUT)
        } else {
            request = NSMutableURLRequest(url: finalURL as URL,
                                          cachePolicy: .useProtocolCachePolicy, timeoutInterval: MP_DEFAULT_TIME_OUT)
        }

        #if DEBUG
            print("\n--REQUEST_URL: \(finalURL)")
        #endif

        request.url = finalURL as URL
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if headers !=  nil && headers!.count > 0 {
            for header in headers! {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        if let body = body {
            #if DEBUG
                print("--REQUEST_BODY: \(body as! NSString)")
            #endif
            request.httpBody = body.data(using: String.Encoding.utf8)
        }

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main) { (response: URLResponse?, data: Data?, error: Error?) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error == nil && data != nil {
                do {
                    #if DEBUG
                        print("--REQUEST_RESPONSE: \(String(data: data!, encoding: String.Encoding.utf8) as! NSString)\n")
                    #endif
                    success(data!)
                } catch {

                    let e: NSError = NSError(domain: "com.mercadopago.sdk", code: NSURLErrorCannotDecodeContentData, userInfo: nil)
                    failure?(e)
                }
            } else {
                failure?(error! as NSError)
            }
        }
    }
}
