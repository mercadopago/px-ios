//
//  JSONHandler.swift
//  MercadoPagoPXTracking
//
//  Created by Eden Torres on 10/30/17.
//  Copyright © 2017 Mercado Pago. All rights reserved.
//

import Foundation
class JSONHandler: NSObject {

    class func jsonCoding(_ jsonDictionary: [String:Any]) -> String {
        var result: String = ""
        do {
            let dict = NSMutableDictionary()
            for (key, value) in jsonDictionary {
                if let value = value as? AnyObject {
                    dict.setValue(value, forKey: key)
                }
            }
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            result = NSString(data: jsonData, encoding: String.Encoding.ascii.rawValue)  as! String
        } catch {
            print("ERROR CONVERTING ARRAY TO JSON, ERROR = \(error)")
        }
        return result

    }

    class func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
