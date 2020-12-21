//
//  CustomService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

internal class CustomService: MercadoPagoService {

    open var data: NSMutableData = NSMutableData()
    
    var URI: String

    init (baseURL: String, URI: String) {
        self.URI = URI
        super.init(baseURL: baseURL)
    }

    internal func createPayment(headers: [String: String]? = nil, body: Data, params: String?, success: @escaping (_ jsonResult: PXPayment) -> Void, failure: ((_ error: PXError) -> Void)?) {

        self.request(uri: self.URI, params: params, body: body, method: HTTPMethod.post, headers: headers, cache: false, success: { (data: Data) -> Void in
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                if let paymentDic = jsonResult as? NSDictionary {
                    if paymentDic["error"] != nil {
                        if paymentDic["status"] as? Int == ApiErrorCode.PROCESSING {
                            let inProcessPayment = PXPayment(id: 0, status: PXPayment.Status.IN_PROCESS)
                            inProcessPayment.status = PXPayment.Status.IN_PROCESS
                            inProcessPayment.statusDetail = PXPayment.StatusDetails.PENDING_CONTINGENCY
                            success(inProcessPayment)
                        } else {
                            let apiException = try JSONDecoder().decode(PXApiException.self, from: data) as PXApiException
                            failure?(PXError(domain: ApiDomain.CREATE_PAYMENT, code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: paymentDic as? [String: Any], apiException: apiException))
                        }
                    } else {
                        if paymentDic.allKeys.count > 0 {
                            let payment = try PXPayment.fromJSON(data: data)
                            success(payment)
                        } else {
                            failure?(PXError(domain: ApiDomain.CREATE_PAYMENT, code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: ["message": "PAYMENT_ERROR"]))
                        }
                    }
                } else {
                    failure?(PXError(domain: ApiDomain.CREATE_PAYMENT, code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: ["message": "Response cannot be decoded"]))
                }
            } catch {
                failure?(PXError(domain: ApiDomain.CREATE_PAYMENT, code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido crear el pago"]))
            }
        }, failure: { (_) -> Void in
            if let failure = failure {
                failure(PXError(domain: ApiDomain.CREATE_PAYMENT, code: ErrorTypes.NO_INTERNET_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
            }
        })
    }

    internal func getPointsAndDiscounts(headers: [String: String]? = nil, body: Data?, params: String?, success: @escaping (_ jsonResult: PXPointsAndDiscounts) -> Void, failure: (() -> Void)?) {

            self.request(uri: self.URI, params: params, body: body, method: HTTPMethod.get, headers: headers, cache: false, success: { (data: Data) -> Void in
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    if let pointsDic = jsonResult as? NSDictionary {
                        if pointsDic["error"] != nil {
                                failure?()
                        } else {
                            if pointsDic.allKeys.count > 0 {
                                let pointsAndDiscounts = try JSONDecoder().decode(PXPointsAndDiscounts.self, from: data)
                                success(pointsAndDiscounts)
                            } else {
                                failure?()
                            }
                        }
                    } else {
                        failure?()
                    }
                } catch {
                    failure?()
                }
            }, failure: { (_) -> Void in
                if let failure = failure {
                    failure()
                }
            })
        }

    internal func resetESCCap(params: String, success: @escaping () -> Void, failure: ((_ error: PXError) -> Void)?) {
        self.request(uri: self.URI, params: params, body: nil, method: HTTPMethod.delete, cache: false, success: { (data) in
                success()
        }, failure: { (_) in
                failure?(PXError(domain: ApiDomain.RESET_ESC_CAP, code: ErrorTypes.NO_INTERNET_ERROR, userInfo: ["message": "Response cannot be decoded"]))
        })
    }
}
