//
//  MercadoPagoService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 5/2/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class MercadoPagoService : NSObject {
      
    let MP_DEFAULT_TIME_OUT = 15.0
    
    var baseURL : String!
    init (baseURL : String) {
        super.init()
        self.baseURL = baseURL
    }
    override init (){
        super.init()
    }
    
    
    public func request(uri: String, params: String?, body: AnyObject?, method: String, headers : NSDictionary? = nil, cache: Bool = true, success: @escaping (_ jsonResult: AnyObject?) -> Void,
        failure: ((_ error: NSError) -> Void)?) {
        
        var url = baseURL + uri
        if params != nil {
            url += "?" + params!
        }
        
        let finalURL: NSURL = NSURL(string: url)!
            let request : NSMutableURLRequest
            if(cache){
              request  = NSMutableURLRequest(url: finalURL as URL,
                    cachePolicy: .returnCacheDataElseLoad, timeoutInterval: MP_DEFAULT_TIME_OUT)
            }else{
               request = NSMutableURLRequest(url: finalURL as URL,
                    cachePolicy: .useProtocolCachePolicy, timeoutInterval: MP_DEFAULT_TIME_OUT)
            }
            
            
        request.url = finalURL as URL
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if headers !=  nil && headers!.count > 0 {
            for header in headers! {
                request.setValue(header.value as? String, forHTTPHeaderField: header.key as! String)
            }
        }
        
        if body != nil {
            request.httpBody = (body as! NSString).data(using: String.Encoding.utf8.rawValue)
        }

		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		

		NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main) { (response: URLResponse?, data: Data?, error: Error?) in
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				if error == nil {
					do
					{

                        let responseJson = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments)
						success(responseJson as AnyObject?)
					} catch {
                        
						let e : NSError = NSError(domain: "com.mercadopago.sdk", code: NSURLErrorCannotDecodeContentData, userInfo: nil)
						failure!(e)
					}
                } else {

                    let response = String(describing: error)
             
                    if failure != nil {
                        failure!(error! as NSError)
                    }
                }
        }
    }
    
    
    }
    
    
    

