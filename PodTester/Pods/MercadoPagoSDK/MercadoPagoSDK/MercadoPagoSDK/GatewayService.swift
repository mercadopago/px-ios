//
//  GatewayService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 29/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

open class GatewayService : MercadoPagoService {
    
    open func getToken(_ url : String = MercadoPago.MP_OP_ENVIROMENT + "/card_tokens", method : String = "POST", public_key : String, savedCardToken : SavedCardToken, success: @escaping (_ jsonResult: AnyObject?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        self.request(uri: url, params: "public_key=" + public_key, body: savedCardToken.toJSONString() as AnyObject?, method: method, success: success, failure: failure)
    }
    
    open func getToken(_ url : String = MercadoPago.MP_OP_ENVIROMENT + "/card_tokens", method : String = "POST", public_key : String, cardToken : CardToken, success: @escaping (_ jsonResult: AnyObject?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        self.request(uri: url, params: "public_key=" + public_key, body: cardToken.toJSONString() as AnyObject?, method: method, success: success, failure: failure)
    }
    
    open func cloneToken(_ url : String = MercadoPago.MP_OP_ENVIROMENT + "/card_tokens", method : String = "POST", public_key : String, token : Token, securityCode:String, success: @escaping (_ jsonResult: AnyObject?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        self.request(uri: url + "/" + token._id + "/clone", params: "public_key=" + public_key, body: nil, method: method, success: { (jsonResult) in
            var token : Token? = nil
            if let tokenDic = jsonResult as? NSDictionary {
                if tokenDic["error"] == nil {
                    token = Token.fromJSON(tokenDic)
                }
            }
            let secCodeDic : [String:Any] = ["security_code":securityCode]

            self.request(uri: url + "/" + token!._id, params: "public_key=" + public_key, body: JSONHandler.jsonCoding(secCodeDic) as AnyObject?, method: "PUT", success: success, failure: failure)
        }, failure:failure)
 
        
    }
    
    
}
