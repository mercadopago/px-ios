//
//  CustomService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import MercadoPagoPXTracking

open class CustomService: MercadoPagoService {

    open var data: NSMutableData = NSMutableData()

    var URI: String

    init (baseURL: String, URI: String) {
        self.URI = URI
        super.init(baseURL: baseURL)
    }

    open func getCustomer(_ method: String = "GET", params: String, success: @escaping (_ jsonResult: PXCustomer) -> Void, failure: ((_ error: PXError) -> Void)?) {

        self.request(uri: self.URI, params: params, body: nil, method: method, cache: false, success: { (data) -> Void in
          let jsonResult = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments)
            if let custDic = jsonResult as? NSDictionary {
                if custDic["error"] != nil {
                    if failure != nil {
                        let apiException = try! PXApiException.fromJSON(data: data)
                        failure!(PXError(domain: "mercadopago.sdk.customServer.getCustomer", code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: custDic as! [String: Any], apiException: apiException))
                    }
                } else {
                    let customer: PXCustomer = try! PXCustomer.fromJSONToPXCustomer(data: data)
                    success(customer)
                }
            } else {
                if failure != nil {
                    failure!(PXError(domain: "mercadopago.sdk.customServer.getCustomer", code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: ["message": "Response cannot be decoded"]))
                }
            }
        }, failure: { (error) in
            failure?(PXError(domain: "mercadopago.sdk.customServer.getCustomer", code: ErrorTypes.NO_INTERNET_ERROR, userInfo: ["message": "Response cannot be decoded"]))
        })
    }

    open func createPayment(_ method: String = "POST", headers: [String: String]? = nil, body: String, params: String?, success: @escaping (_ jsonResult: PXPayment) -> Void, failure: ((_ error: PXError) -> Void)?) {

        self.request(uri: self.URI, params: params, body: body, method: method, headers : headers, cache: false, success: { (data: Data) -> Void in
                            let jsonResult = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments)
            if let paymentDic = jsonResult as? NSDictionary {
                if paymentDic["error"] != nil {
                    if paymentDic["status"] as? Int == PXApitUtil.PROCESSING {
                        let inProcessPayment = PXPayment()
                        inProcessPayment.status = PXPayment.Status.IN_PROCESS
                        inProcessPayment.statusDetail = PXPayment.StatusDetails.PENDING_CONTINGENCY
                        success(inProcessPayment)
                    } else if failure != nil {
                        let apiException = try! PXApiException.fromJSON(data: data)
                        failure!(PXError(domain: "mercadopago.sdk.customServer.createPayment", code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: paymentDic as! [String: Any], apiException: apiException))
                    }
                } else {
                    if paymentDic.allKeys.count > 0 {
                        let payment = try! PXPayment.fromJSON(data: data)
                        if !payment.isCardPaymentType() {
                            MPXTracker.trackPaymentOff(paymentId: payment.id.stringValue)
                        }
                        success(payment)
                    } else {
                        failure?(PXError(domain: "mercadopago.sdk.customServer.createPayment", code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: ["message": "PAYMENT_ERROR"]))
                    }
                }
            } else if failure != nil {
                failure!(PXError(domain: "mercadopago.sdk.customServer.createPayment", code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: ["message": "Response cannot be decoded"]))
            }}, failure: { (error) -> Void in
                if let failure = failure {
                    failure(PXError(domain: "mercadopago.sdk.CustomService.createPayment", code: ErrorTypes.NO_INTERNET_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
                }
        })
    }

    open func createPreference(_ method: String = "POST", body: String?, success: @escaping (_ jsonResult: PXCheckoutPreference) -> Void, failure: ((_ error: PXError) -> Void)?) {

        self.request(uri: self.URI, params: nil, body: body, method: method, cache: false, success: {
            (data) in

            let jsonResult = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments)

            if let preferenceDic = jsonResult as? NSDictionary {
                if preferenceDic["error"] != nil && failure != nil {
                    let apiException = try! PXApiException.fromJSON(data: data)
                    failure!(PXError(domain: "mercadopago.customServer.createCheckoutPreference", code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: ["message": "PREFERENCE_ERROR"], apiException: apiException))
                } else {
                    if preferenceDic.allKeys.count > 0 {
                        success(try! PXCheckoutPreference.fromJSON(data: data))
                    } else {
                        failure?(PXError(domain: "mercadopago.customServer.createCheckoutPreference", code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: ["message": "PREFERENCE_ERROR"]))
                    }
                }
            } else {
                failure?(PXError(domain: "mercadopago.sdk.customServer.createCheckoutPreference", code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: ["message": "Response cannot be decoded"]))

            }}, failure: { (error) in
                 failure?(PXError(domain: "mercadopago.sdk.customServer.createCheckoutPreference", code: ErrorTypes.NO_INTERNET_ERROR, userInfo: ["message": "Response cannot be decoded"]))
        })
    }
}
