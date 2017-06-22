//
//  MPXTracker.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 6/1/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

protocol MPXTracker {
    static var mpxPublicKey: String {get}
    static var mpxCheckoutVersion: String {get}
    static var mpxPlatform: String {get}
    static var mpxSiteId: String {get}
    static var mpxPlatformType: String {get}
}

extension MPXTracker {
    static func trackScreen(screenId: String, screenName: String) {
        let body = JSONHandler.jsonCoding(generateJSONScreen(screenId: screenId, screenName: screenName))
        self.request(url: "https://api.mercadopago.com/beta/checkout/tracking/events", params: nil, body: body, method: "POST", headers: nil, success: { (result) -> Void in
        }) { (error) -> Void in
        }
    }
    static private func generateJSONDefault() -> [String:Any] {
        let clientId = UIDevice.current.identifierForVendor!.uuidString
        let deviceJSON = MPTDevice().toJSON()
        let applicationJSON = MPTApplication(publicKey: mpxPublicKey, checkoutVersion: mpxCheckoutVersion, platform: mpxPlatform).toJSON()
        let obj: [String:Any] = [
            "client_id": clientId,
            "application": applicationJSON,
            "device": deviceJSON,
            ]
        return obj
    }
    static func generateJSONScreen(screenId: String, screenName: String) -> [String:Any] {
        var obj = Self.generateJSONDefault()
        let screenJSON = Self.screenJSON(screenId: screenId, screenName: screenName)
        obj["events"] = [screenJSON]
        return obj
    }
    static func trackEvent(screenId: String, screenName: String, action: String, category: String, label: String, value: String) {
        let body = JSONHandler.jsonCoding(generateJSONEvent(screenId: screenId, screenName: screenName, action: action, category: category, label: label, value: value))
        self.request(url: "https://api.mercadopago.com/beta/checkout/tracking/events", params: nil, body: body, method: "POST", headers: nil, success: { (result) -> Void in
        }) { (error) -> Void in
        }
    }
    static func generateJSONEvent(screenId: String, screenName: String, action: String, category: String, label: String, value: String) -> [String:Any] {
        var obj = Self.generateJSONDefault()
        let eventJSON = Self.eventJSON(screenId: screenId, screenName: screenName, action: action, category: category, label: label, value: value)
        obj["events"] = [eventJSON]
        return obj
    }
    static func eventJSON(screenId: String, screenName: String, action: String, category: String, label: String, value: String) -> [String:Any] {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let timestamp = formatter.string(from: date).replacingOccurrences(of: " ", with: "T")
        let obj: [String:Any] = [
            "timestamp": timestamp,
            "type": "action",
            "screen_id": screenId,
            "screen_name": screenName,
            "action": action,
            "category": category,
            "label": label,
            "value": value
        ]
        return obj
    }
    static func screenJSON(screenId: String, screenName: String) -> [String:Any] {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let timestamp = formatter.string(from: date).replacingOccurrences(of: " ", with: "T")
        let obj: [String:Any] = [
            "timestamp": timestamp,
            "type": "screenview",
            "screen_id": screenId,
            "screen_name": screenName
        ]
        return obj
    }
    static func request(url: String, params: String?, body: String? = nil, method: String, headers: [String:String]? = nil, success: @escaping (Any) -> Void,
                              failure: ((NSError) -> Void)?) {
        var requesturl = url
        if params != nil && !(params?.isEmpty)! {
            requesturl += "?" + params!
        }
        let finalURL: NSURL = NSURL(string: url)!
        let request: NSMutableURLRequest
        request = NSMutableURLRequest(url: finalURL as URL)
        request.url = finalURL as URL
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if headers !=  nil && headers!.count > 0 {
            for header in headers! {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        if let body = body {
            request.httpBody = body.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        }
        var session = URLSession.shared
        var task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error == nil {
                do {
                    let responseJson = try JSONSerialization.jsonObject(with: data!,
                                                                        options:JSONSerialization.ReadingOptions.allowFragments)
                    if let paymentDic = responseJson as? NSDictionary { 
                        if paymentDic["status"] as? Int == 200 {
                            print("200!")
                        }else{
                            print("Codigo = \(paymentDic["status"])")
                        }
                    }
                    success(responseJson as Any)
                } catch {
                    let e: NSError = NSError(domain: "com.mercadopago.sdk", code: NSURLErrorCannotDecodeContentData, userInfo: nil)
                    failure?(e)
                }
            } else {
                if failure != nil {
                    failure!(error! as NSError)
                }
            }})
        
        task.resume()
        /*
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main) { (response: URLResponse?, data: Data?, error: Error?) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error == nil {
                do {
                    let responseJson = try JSONSerialization.jsonObject(with: data!,
                                                                        options:JSONSerialization.ReadingOptions.allowFragments)
                    success(responseJson as Any)
                } catch {
                    let e: NSError = NSError(domain: "com.mercadopago.sdk", code: NSURLErrorCannotDecodeContentData, userInfo: nil)
                    failure!(e)
                }
            } else {
                if failure != nil {
                    failure!(error! as NSError)
                }
            }
        }
    */
    }
}
