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
    open var errorDetail: String = ""
    open var retry: Bool?

    public override init() {
        super.init()
    }

    public init(message: String, errorDetail: String, retry: Bool!) {
        super.init()
        self.message = message
        self.errorDetail = errorDetail
        self.retry = retry
    }

    open class func convertFrom(_ error: Error) -> MPSDKError {
        let mpError = MPSDKError()
        let currentError = error as NSError

        if currentError.userInfo.count > 0 {
            let errorMessage = currentError.userInfo[NSLocalizedDescriptionKey] as? String ?? ""
            mpError.message = errorMessage.localized
            let messageDetail = currentError.userInfo[NSLocalizedFailureReasonErrorKey] as? String ?? ""
            mpError.errorDetail = messageDetail.localized
        }
        mpError.retry = (currentError.code == MercadoPago.ERROR_API_CODE || currentError.code == NSURLErrorCannotDecodeContentData || currentError.code == NSURLErrorNotConnectedToInternet || currentError.code == NSURLErrorTimedOut)
        return mpError
    }

    func toJSON() -> [String:Any] {
        let obj: [String:Any] = [
            "message": self.message,
            "error_detail": self.errorDetail,
            "recoverable": self.retry ?? true
        ]
        return obj
    }

    func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

}
