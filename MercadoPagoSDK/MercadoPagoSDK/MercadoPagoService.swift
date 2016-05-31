//
//  MercadoPagoService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 5/2/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

public class MercadoPagoService : NSObject, NSURLConnectionDataDelegate {

    static let MP_BASE_URL = "https://api.mercadopago.com"
    var delegate : NSURLConnectionDataDelegate!
    var baseURL : String!
    
    init (baseURL : String) {
        super.init()
        self.baseURL = baseURL
        
    }

    public func request(uri: String, params: String?, body: AnyObject?, method: String, headers : NSDictionary? = nil, success: (jsonResult: AnyObject?) -> Void,
        failure: ((error: NSError) -> Void)?) {
        
        delegate = self
        var url = baseURL + uri
        if params != nil {
            url += "?" + params!
        }
        
        let finalURL: NSURL = NSURL(string: url)!
        let request = NSURLRequest(URL: finalURL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 60.0) //NSMutableURLRequest = NSMutableURLRequest()
        //request.URL = finalURL
        //request.HTTPMethod = method
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if headers !=  nil && headers!.count > 0 {
            for header in headers! {
          //      request.setValue(header.value as! String, forHTTPHeaderField: header.key as! String)
            }
        }
        
        if body != nil {
            //request.HTTPBody = (body as! NSString).dataUsingEncoding(NSUTF8StringEncoding)
        }

		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		
        
        //request.cachePolicy = NSURLRequestCachePolicy
        let requestBeganAt  = NSDate()
        print("*************** REQUEST AT " + String(requestBeganAt) + " *************")
        print(request)


		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) in
            
            
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				if error == nil {
					do
					{
                        let requestFinishedAt = NSDate()
                        print("*************** RESPONSE AT " + String(requestFinishedAt))
                        let response = try NSJSONSerialization.JSONObjectWithData(data!,
                                                                              options:NSJSONReadingOptions.AllowFragments)
                        print(response)
                        //let totalTime = requestFinishedAt
                      //  print("*************** REQUEST TOOK :" + String(totalTime) + " *************")
						success(jsonResult: try NSJSONSerialization.JSONObjectWithData(data!,
							options:NSJSONReadingOptions.AllowFragments))
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
    
    public func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        print("***** STATUS CODE RESPONSE ******")
        if response.isKindOfClass(NSHTTPURLResponse) {
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            print("***** " + String(statusCode) + " *****")
        }
    }
    
    public func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        let receivedData = NSMutableData(data: data)
    
    }
    
}