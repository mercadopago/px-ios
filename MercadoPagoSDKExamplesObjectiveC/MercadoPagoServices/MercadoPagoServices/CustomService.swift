//
//  CustomService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

open class CustomService: MercadoPagoService {

    open var data: NSMutableData = NSMutableData()

    var URI: String

    init (baseURL: String, URI: String) {
        self.URI = URI
        super.init()
        self.baseURL = baseURL
    }

    open func getCustomer(_ method: String = "GET", params: String, success: @escaping (_ jsonResult: PXCustomer) -> Void, failure: ((_ error: NSError) -> Void)?) {

        self.request(uri: self.URI, params: params, body: nil, method: method, cache: false, success: { (data) -> Void in
          let jsonResult = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments)
            if let custDic = jsonResult as? NSDictionary {
                if custDic["error"] != nil {
                    if failure != nil {
                        failure!(NSError(domain: "mercadopago.sdk.customServer.getCustomer", code: PXApitUtil.ERROR_API_CODE, userInfo: custDic as! [String : Any]))
                    }
                } else {
                    let customer: PXCustomer = try! PXCustomer.fromJSON(data: data)
                    success(customer)
                }
            } else {
                if failure != nil {
                    failure!(NSError(domain: "mercadopago.sdk.customServer.getCustomer", code: PXApitUtil.ERROR_UNKNOWN_CODE, userInfo: ["message": "Response cannot be decoded"]))
                }
            }
        }, failure: failure)
    }

    open func createPayment(_ method: String = "POST", headers: [String:String]? = nil, body: String, success: @escaping (_ jsonResult: PXPayment) -> Void, failure: ((_ error: NSError) -> Void)?) {

        self.request(uri: self.URI, params: nil, body: body, method: method, headers : headers, cache: false, success: { (data: Data) -> Void in
                            let jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments)
            if let paymentDic = jsonResult as? NSDictionary {
                if paymentDic["error"] != nil {
                    if paymentDic["status"] as? Int == PXApitUtil.PROCESSING {
                        let inProcessPayment = PXPayment()
                        inProcessPayment.status = PXPayment.Status.IN_PROCESS
                        inProcessPayment.statusDetail = PXPayment.StatusDetails.PENDING_CONTINGENCY
                        success(inProcessPayment)
                    } else if failure != nil {
                        failure!(NSError(domain: "mercadopago.sdk.customServer.createPayment", code: PXApitUtil.ERROR_API_CODE, userInfo: paymentDic as! [String : Any]))
                    }
                } else {
                    if paymentDic.allKeys.count > 0 {
                        success(try! PXPayment.fromJSON(data: data))
                    } else {
                        failure?(NSError(domain: "mercadopago.sdk.customServer.createPayment", code: PXApitUtil.ERROR_PAYMENT, userInfo: ["message": "PAYMENT_ERROR"]))
                    }
                }
            } else if failure != nil {
                failure!(NSError(domain: "mercadopago.sdk.customServer.createPayment", code: PXApitUtil.ERROR_UNKNOWN_CODE, userInfo: ["message": "Response cannot be decoded"]))
            }} as! (Data?) -> Void, failure: { (error) -> Void in
                if let failure = failure {
                    failure(NSError(domain: "mercadopago.sdk.CustomService.createPayment", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
                }
        })
    }

    open func createPreference(_ method: String = "POST", body: String?, success: @escaping (_ jsonResult: PXCheckoutPreference) -> Void, failure: ((_ error: NSError) -> Void)?) {

        self.request(uri: self.URI, params: nil, body: body, method: method, cache: false, success: {
            (data) in

            let jsonResult = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments)

            if let preferenceDic = jsonResult as? NSDictionary {
                if preferenceDic["error"] != nil && failure != nil {
                    failure!(NSError(domain: "mercadopago.customServer.createCheckoutPreference", code: PXApitUtil.ERROR_API_CODE, userInfo: ["message": "PREFERENCE_ERROR"]))
                } else {
                    if preferenceDic.allKeys.count > 0 {
                        success(try! PXCheckoutPreference.fromJSON(data: data))
                    } else {
                        failure?(NSError(domain: "mercadopago.customServer.createCheckoutPreference", code: PXApitUtil.ERROR_UNKNOWN_CODE, userInfo: ["message": "PREFERENCE_ERROR"]))
                    }
                }
            } else {
                failure?(NSError(domain: "mercadopago.sdk.customServer.createCheckoutPreference", code: PXApitUtil.ERROR_UNKNOWN_CODE, userInfo: ["message": "Response cannot be decoded"]))
            }}, failure: failure)
    }
}
