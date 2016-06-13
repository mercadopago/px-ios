//
//  MercadoPagoService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 5/2/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

public class MercadoPagoService : NSObject {

    static let MP_BASE_URL = "https://api.mercadopago.com"
    
    let MP_DEFAULT_TIME_OUT = 15.0
    
    var baseURL : String!
    init (baseURL : String) {
        super.init()
        self.baseURL = baseURL
    }
    
    public func request(uri: String, params: String?, body: AnyObject?, method: String, headers : NSDictionary? = nil, cache: Bool = true, success: (jsonResult: AnyObject?) -> Void,
        failure: ((error: NSError) -> Void)?) {
        
        var url = baseURL + uri
        if params != nil {
            url += "?" + params!
        }
        
        let finalURL: NSURL = NSURL(string: url)!
            let request : NSMutableURLRequest
            if(cache){
              request  = NSMutableURLRequest(URL: finalURL,
                    cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: MP_DEFAULT_TIME_OUT)
            }else{
               request = NSMutableURLRequest(URL: finalURL,
                    cachePolicy: .UseProtocolCachePolicy, timeoutInterval: MP_DEFAULT_TIME_OUT)
            }
            
            
        request.URL = finalURL
        request.HTTPMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if headers !=  nil && headers!.count > 0 {
            for header in headers! {
                request.setValue(header.value as! String, forHTTPHeaderField: header.key as! String)
            }
        }
        
        if body != nil {
            request.HTTPBody = (body as! NSString).dataUsingEncoding(NSUTF8StringEncoding)
        }

		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		
        let requestBeganAt  = NSDate()
        print("*************** REQUEST AT " + String(requestBeganAt) + " *************")
		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) in
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				if error == nil {
					do
					{
                        let requestFinishedAt = NSDate()
                        print("*************** RESPONSE AT " + String(requestFinishedAt))
                        let response = try NSJSONSerialization.JSONObjectWithData(data!,
                                                                              options:NSJSONReadingOptions.AllowFragments)
                        let responseJson = try NSJSONSerialization.JSONObjectWithData(data!,
                                                                   options:NSJSONReadingOptions.AllowFragments)
						success(jsonResult: responseJson)
					} catch {
                        
						let e : NSError = NSError(domain: "com.mercadopago.sdk", code: NSURLErrorCannotDecodeContentData, userInfo: nil)
						failure!(error: e)
					}
                } else {
                    let requestFinishedAt = NSDate()
                    print("*************** RESPONSE AT " + String(requestFinishedAt))
                    let response = String(error)
                    print(response)

                    if failure != nil {
                        failure!(error: error!)
                    }
                }
        }
    }
}