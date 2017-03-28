//
//  PaymentTracker.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 6/13/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class PaymentTracker: NSObject {

    static let MP_TRACK_TOKEN_URL = "https://api.mercadopago.com/v1/checkout/tracking"
    static let MP_TRACK_PAYMENTOFF_URL = "https://api.mercadopago.com/v1/checkout/tracking/off"

    
    var baseURL : String!
    init (baseURL : String) {
        super.init()
        self.baseURL = baseURL
    }

    public class func trackToken(token: String!, delegate : MPTrackerDelegate!){
        
        let obj:[String:Any] = ["public_key": delegate.publicKey() , "token":token! ,"sdk_flavor":(delegate.flavor()?.rawValue)! ,"sdk_platform":"iOS" ,"sdk_type":FlowTrackInfo.getSdkType() ,"sdk_version":delegate.sdkVersion() ,"sdk_framework":"" ,"site_id":delegate.siteId() ]
    
            
            self.request(url: PaymentTracker.MP_TRACK_TOKEN_URL, params: nil, body: JSONHandler.jsonCoding(obj), method: "POST", headers: nil, success: { (jsonResult) -> Void in
                
            }) { (error) -> Void in
                
            }
       
       
    }
   
    
    public class func trackPaymentOff(paymentId: String!, delegate : MPTrackerDelegate!){
        
        let obj:[String:Any] = ["public_key":delegate.publicKey() , "payment_id":paymentId!,"sdk_flavor":(delegate.flavor()?.rawValue)!,"sdk_platform":"iOS" ,"sdk_type":FlowTrackInfo.getSdkType() ,"sdk_version":delegate.sdkVersion() ,"sdk_framework":"" ,"site_id" :delegate.siteId() ]
        
        self.request(url: PaymentTracker.MP_TRACK_PAYMENTOFF_URL, params: nil, body: JSONHandler.jsonCoding(obj), method: "POST", headers: nil, success: { (jsonResult) -> Void in
            
            }) { (error) -> Void in
                
        }
    }
    
    public class func request(url: String, params: String?, body: Any, method: String, headers : NSDictionary? = nil,  success: @escaping (Any) -> Void,
        failure: ((NSError) -> Void)?) {
            
            var requesturl = url
            if params != nil {
                requesturl += "?" + params!
            }
            
            let finalURL: NSURL = NSURL(string: url)!
            let request : NSMutableURLRequest
            
                request = NSMutableURLRequest(url: finalURL as URL)
    
            
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
        
    
            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main) { (response: URLResponse?, data: Data?, error: Error?) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if error == nil {
                do
                {
                    let responseJson = try JSONSerialization.jsonObject(with: data!,
                                                                                  options:JSONSerialization.ReadingOptions.allowFragments)
                    success(responseJson as Any)
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
