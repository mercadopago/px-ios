//
//  GatewayService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 29/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

public class GatewayService : MercadoPagoService {
    
    public func getToken(url : String = MercadoPago.MP_OP_ENVIROMENT + "/card_tokens", method : String = "POST", public_key : String, savedCardToken : SavedCardToken, success: (jsonResult: AnyObject?) -> Void, failure: ((error: NSError) -> Void)?) {
        self.request(url, params: "public_key=" + public_key, body: savedCardToken.toJSONString(), method: method, success: success, failure: failure)
    }
    
    public func getToken(url : String = MercadoPago.MP_OP_ENVIROMENT + "/card_tokens", method : String = "POST", public_key : String, cardToken : CardToken, success: (jsonResult: AnyObject?) -> Void, failure: ((error: NSError) -> Void)?) {
        self.request(url, params: "public_key=" + public_key, body: cardToken.toJSONString(), method: method, success: success, failure: failure)
    }
    
    public func cloneToken(url : String = MercadoPago.MP_OP_ENVIROMENT + "/card_tokens", method : String = "POST", public_key : String, token : Token, securityCode:String, success: (jsonResult: AnyObject?) -> Void, failure: ((error: NSError) -> Void)?) {
        self.request(url + "/" + token._id + "/clone", params: "public_key=" + public_key, body: nil, method: method, success: { (jsonResult) in
            var token : Token? = nil
            if let tokenDic = jsonResult as? NSDictionary {
                if tokenDic["error"] == nil {
                    token = Token.fromJSON(tokenDic)
                }
            }
            var secCodeDic = NSMutableDictionary()
            secCodeDic.setValue(securityCode, forKey: "security_code")
            self.request(url + "/" + token!._id, params: "public_key=" + public_key, body: JSON(secCodeDic).toString(), method: "PUT", success: success, failure: failure)
        }, failure:failure)
 
        
    }
    
    
}