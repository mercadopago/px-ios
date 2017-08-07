//
//  MPError.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 17/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class MPSDKError: NSObject {

    open var message: String = ""
    open var messageDetail: String = ""
    open var apiException: ApiException?
    open var retry: Bool?

    public override init() {
        super.init()
    }

    public init(message: String, messageDetail: String, retry: Bool!) {
        super.init()
        self.message = message
        self.messageDetail = messageDetail
        self.retry = retry
    }

    open class func convertFrom(_ error: Error) -> MPSDKError {
        let mpError = MPSDKError()
        let currentError = error as NSError
        if currentError.userInfo.count > 0 {
            let errorMessage = currentError.userInfo[NSLocalizedDescriptionKey] as? String ?? ""
            mpError.message = errorMessage.localized
            let messageDetail = currentError.userInfo[NSLocalizedFailureReasonErrorKey] as? String ?? ""
            mpError.messageDetail = messageDetail.localized
            mpError.apiException = ApiException.fromJSON(currentError.userInfo as NSDictionary)
        }
        mpError.retry = (currentError.code == MercadoPago.ERROR_API_CODE || currentError.code == NSURLErrorCannotDecodeContentData || currentError.code == NSURLErrorNotConnectedToInternet || currentError.code == NSURLErrorTimedOut)
        return mpError
    }

}
