//
//  CustomService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class CustomService: MercadoPagoService {

    open var data: NSMutableData = NSMutableData()

    var URI: String

    init (baseURL: String, URI: String) {
        self.URI = URI
        super.init()
        self.baseURL = baseURL
    }

    open func getCustomer(_ method: String = "GET", params: String, success: @escaping (_ jsonResult: Customer) -> Void, failure: ((_ error: NSError) -> Void)?) {

        self.request(uri: self.URI, params: params, body: nil, method: method, cache: false, success: { (jsonResult) -> Void in
            if let custDic = jsonResult as? NSDictionary {
                if custDic["error"] != nil {
                    if failure != nil {
                        failure!(NSError(domain: "mercadopago.sdk.customServer.getCustomer", code: MercadoPago.ERROR_API_CODE, userInfo: custDic as! [AnyHashable: AnyObject]))
                    }
                } else {
                    success(Customer.fromJSON(custDic))
                }
            } else {
                if failure != nil {
                    failure!(NSError(domain: "mercadopago.sdk.customServer.getCustomer", code: MercadoPago.ERROR_UNKNOWN_CODE, userInfo: ["message": "Response cannot be decoded"]))
                }
            }
        }, failure: failure)
    }

    open func createPayment(_ method: String = "POST", body: String, success: @escaping (_ jsonResult: Payment) -> Void, failure: ((_ error: NSError) -> Void)?) {

        let headers = [MercadoPagoContext.paymentKey(): "X-Idempotency-Key"]

        self.request(uri: self.URI, params: nil, body: body, method: method, headers : headers, cache: false, success: { (jsonResult: AnyObject?) -> Void in
            if let paymentDic = jsonResult as? NSDictionary {
                if paymentDic["error"] != nil {
                    if paymentDic["status"] as? Int == ApiUtil.StatusCodes.PROCESSING.rawValue {
                        let inProcessPayment = Payment()
                        inProcessPayment.status = PaymentStatus.IN_PROCESS
                        inProcessPayment.statusDetail = PendingStatusDetail.CONTINGENCY
                        success(inProcessPayment)
                    } else if failure != nil {
                        failure!(NSError(domain: "mercadopago.sdk.customServer.createPayment", code: MercadoPago.ERROR_API_CODE, userInfo: paymentDic as! [AnyHashable: AnyObject]))
                    }
                } else {
                    if paymentDic.allKeys.count > 0 {
                        success(Payment.fromJSON(paymentDic))
                    } else {
                        failure?(NSError(domain: "mercadopago.sdk.customServer.createPayment", code: MercadoPago.ERROR_PAYMENT, userInfo: ["message": "PAYMENT_ERROR".localized]))
                    }
                }
            } else if failure != nil {
                failure!(NSError(domain: "mercadopago.sdk.customServer.createPayment", code: MercadoPago.ERROR_UNKNOWN_CODE, userInfo: ["message": "Response cannot be decoded"]))
            }}, failure: { (error) -> Void in
                if let failure = failure {
                    failure(NSError(domain: "mercadopago.sdk.CustomService.createPayment", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente".localized]))
                }
        })
    }

    open func createPreference(_ method: String = "POST", body: String, success: @escaping (_ jsonResult: CheckoutPreference) -> Void, failure: ((_ error: NSError) -> Void)?) {

        self.request(uri: self.URI, params: nil, body: body, method: method, cache: false, success: {
            (jsonResult) in

            if let preferenceDic = jsonResult as? NSDictionary {
                if preferenceDic["error"] != nil && failure != nil {
                    failure!(NSError(domain: "mercadopago.customServer.createCheckoutPreference", code: MercadoPago.ERROR_API_CODE, userInfo: ["message": "PREFERENCE_ERROR".localized]))
                } else {
                    if preferenceDic.allKeys.count > 0 {
                        success(CheckoutPreference.fromJSON(preferenceDic))
                    } else {
                        failure?(NSError(domain: "mercadopago.customServer.createCheckoutPreference", code: MercadoPago.ERROR_UNKNOWN_CODE, userInfo: ["message": "PREFERENCE_ERROR".localized]))
                    }
                }
            } else {
                failure?(NSError(domain: "mercadopago.sdk.customServer.createCheckoutPreference", code: MercadoPago.ERROR_UNKNOWN_CODE, userInfo: ["message": "Response cannot be decoded"]))
            }}, failure: failure)
    }
}
