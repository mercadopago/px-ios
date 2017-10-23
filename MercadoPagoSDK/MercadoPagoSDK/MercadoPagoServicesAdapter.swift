//
//  MercadoPagoServicesAdapter.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 10/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class MercadoPagoServicesAdapter: NSObject {

    open class func getInstallments(bin: String?, amount: Double, issuer: Issuer?, paymentMethodId: String, callback: @escaping ([Installment]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        var issuerId: Int64!
        if let id = Int64((issuer?._id)!) {
            issuerId = id
        } else {
            issuerId = nil
        }

        MercadoPagoServices.getInstallments(bin: bin, amount: amount, issuerId: issuerId, paymentMethodId: paymentMethodId, callback: { (pxInstallments) in

        }, failure: failure)
    }
}
