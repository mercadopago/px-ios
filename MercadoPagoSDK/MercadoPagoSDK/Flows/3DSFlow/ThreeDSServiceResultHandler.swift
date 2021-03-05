//
//  ThreeDSServiceResultHandler.swift
//  MercadoPagoSDKV4
//
//  Created by Eric Ertl on 05/03/2021.
//

import Foundation

internal protocol ThreeDSServiceResultHandler: NSObjectProtocol {
    func finishFlow(threeDSAuthorization: Bool)
    func finishWithError(error: MPSDKError)
}
