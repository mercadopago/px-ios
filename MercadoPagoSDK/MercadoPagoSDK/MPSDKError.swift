//
//  MPError.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 17/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoServices

open class MPSDKError: NSObject {

    open var message: String = ""
    open var errorDetail: String = ""
    open var apiException: ApiException?
    open var requestOrigin: String = ""
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

    open class func convertFrom(_ error: Error, requestOrigin: String) -> MPSDKError {
        let mpError = MPSDKError()
        let currentError = error as NSError

        if currentError.userInfo.count > 0 {
            let errorMessage = currentError.userInfo[NSLocalizedDescriptionKey] as? String ?? ""
            mpError.message = errorMessage.localized
            mpError.apiException = ApiException.fromJSON(currentError.userInfo as NSDictionary)
            if let apiException = mpError.apiException {
                if apiException.error == nil {
                    let pxError = currentError as? PXError
                    mpError.apiException = MPSDKError.pxApiExceptionToApiException(pxApiException: pxError?.apiException)
                }
            }
            mpError.requestOrigin = requestOrigin
        }
        mpError.retry = (currentError.code == MercadoPago.ERROR_API_CODE || currentError.code == NSURLErrorCannotDecodeContentData || currentError.code == NSURLErrorNotConnectedToInternet || currentError.code == NSURLErrorTimedOut)
        return mpError
    }

    func toJSON() -> [String: Any] {
        let obj: [String: Any] = [
            "message": self.message,
            "error_detail": self.errorDetail,
            "recoverable": self.retry ?? true
        ]
        return obj
    }

    func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    class func pxApiExceptionToApiException(pxApiException: PXApiException?) -> ApiException {
        let apiException = ApiException()
        guard let pxApiException = pxApiException else {
            return apiException
        }
        if !Array.isNullOrEmpty(pxApiException.cause) {
            for pxCause in pxApiException.cause! {
                let cause = pxCauseToCause(pxCause: pxCause)
                if cause != nil {
                    apiException.cause = Array.safeAppend(apiException.cause, cause!)
                }
            }
        }
        apiException.error = pxApiException.error
        apiException.message = pxApiException.message
        apiException.status = pxApiException.status ?? 0
        return apiException
    }

    class func pxCauseToCause(pxCause: PXCause?) -> Cause? {
        guard let pxCause = pxCause else {
            return nil
        }
        let cause = Cause()
        cause._description = pxCause._description
        cause.code = pxCause.code
        return cause
    }

}
