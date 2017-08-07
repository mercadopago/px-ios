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

    open class func getCustomer(url: String, uri: String, additionalInfo: NSDictionary? = nil, _ success: @escaping (_ customer: Customer) -> Void, failure: ((_ error: NSError) -> Void)?) {

        let service: CustomService = CustomService(baseURL: url, URI: uri)

        var addInfo: String = ""
        if !NSDictionary.isNullOrEmpty(additionalInfo), let addInfoDict = additionalInfo {
            addInfo = addInfoDict.parseToQuery()
        }

        service.getCustomer(params: addInfo, success: success, failure: failure)
    }

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

    open class func createCheckoutPreference(url: String, uri: String, bodyInfo: NSDictionary, success: @escaping (_ checkoutPreference: CheckoutPreference) -> Void, failure: ((_ error: NSError) -> Void)?) {

        let service: CustomService = CustomService(baseURL: url, URI: uri)

        let body: String = bodyInfo.toJsonString()

        service.createPreference(body: body, success: success, failure: failure)
    }

    open class func getDirectDiscount(transactionAmount: Double, payerEmail: String?, url: String, uri: String, discountAdditionalInfo: NSDictionary?, success: @escaping (_ discountCoupon: DiscountCoupon?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        getCodeDiscount(discountCode: nil, transactionAmount: transactionAmount, payerEmail: payerEmail, url: url, uri: uri, discountAdditionalInfo: discountAdditionalInfo, success: success, failure: failure)
    }

    open class func getCodeDiscount(discountCode: String?, transactionAmount: Double, payerEmail: String?, url: String, uri: String, discountAdditionalInfo: NSDictionary?, success: @escaping (_ discountCoupon: DiscountCoupon?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        var addInfo: String? = nil
        if !NSDictionary.isNullOrEmpty(discountAdditionalInfo) {
            addInfo = discountAdditionalInfo?.parseToQuery()
        }
        let discountService = DiscountService(baseURL: url, URI: uri)

        discountService.getDiscount(amount: transactionAmount, code: discountCode, payerEmail: payerEmail, additionalInfo: addInfo, success: success, failure: failure)
    }

}
