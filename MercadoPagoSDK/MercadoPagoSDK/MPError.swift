//
//  MPError.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 17/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class MPError: NSObject {

    public var message : String = ""
    public var messageDetail : String = ""
    public var retry : Bool?
    
    public override init(){
        super.init()
    }
    
    public init(message : String, messageDetail : String, retry : Bool!){
        super.init()
        self.message = message
        self.messageDetail = messageDetail
        self.retry = retry
    }
    
    public class func convertFrom(error : NSError) -> MPError {
        let mpError = MPError()
        if error.userInfo.count > 0 {
            mpError.message = error.userInfo[NSLocalizedDescriptionKey] as? String ?? ""
            mpError.messageDetail = error.userInfo[NSLocalizedFailureReasonErrorKey] as? String ?? ""
        }
        mpError.retry = (error.code == MercadoPago.ERROR_API_CODE || error.code == NSURLErrorCannotDecodeContentData || error.code == NSURLErrorNotConnectedToInternet)
        return mpError
    }
    
}