//
//  JSONHandler.swift
//  MPTracker
//
//  Created by Demian Tejo on 9/26/16.
//  Copyright © 2016 Demian Tejo. All rights reserved.
//

import UIKit

class JSONHandler: NSObject {

    /*
    class func jsonCoding(jsonDictionary: [String:Any]) -> Any {
        var result : Any = ""
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
            let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
            result = decoded
        }catch{
            print("ERROR CONVERTING ARRAY TO JSON, ERROR = \(error)")
        }
        return result

    }
    
    class func parseToJSON(data:Data) -> Any{
        var result : Any = []
        do{
            result = try JSONSerialization.jsonObject(with: data, options: [])
        }catch{
            print("ERROR PARSIBNG JSON, ERROR = \(error)")
        }
        return result
    }
    */
    
    //For compiling porpouse
    class func jsonCoding(_ jsonDictionary: [String:Any]) -> String {
        var result : String = ""
        do{
            let dict = NSMutableDictionary()
            for (key,value) in jsonDictionary {
                if let value = value as? AnyObject{
                    dict.setValue(value, forKey: key)
                }
            }
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
          //  let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
            result = NSString(data: jsonData,
                                       encoding: String.Encoding.ascii.rawValue)  as! String
          //  result = (decoded as AnyObject).description
        }catch{
            print("ERROR CONVERTING ARRAY TO JSON, ERROR = \(error)")
        }
        return result
        
    }
    
    class func parseToJSON(_ data:Data) -> Any{
        var result : Any = []
        do{
            result = try JSONSerialization.jsonObject(with: data, options: [])
        }catch{
            print("ERROR PARSIBNG JSON, ERROR = \(error)")
        }
        return result
    }

    
    class func attemptParseToString(_ anyobject: Any?, defaultReturn: String? = nil) -> String?{

        guard let _ = anyobject , let string = (anyobject! as AnyObject).description else {
            return defaultReturn
        }
        if ( string != "<null>" ){
            return string
        }else{
            return defaultReturn
        }
    }
    
    class func attemptParseToBool(_ anyobject: Any?) -> Bool?{
        if anyobject is Bool {
            return anyobject as! Bool?
        }
        guard let string = attemptParseToString(anyobject) else {
            return nil
        }
        return string.toBool()
    }
    
    class func attemptParseToDouble(_ anyobject: Any? , defaultReturn: Double? = nil) -> Double?{
        
        guard let string = attemptParseToString(anyobject) else {
            return defaultReturn
        }
        return Double(string) ?? defaultReturn
    }
    class func attemptParseToInt(_ anyobject: Any?, defaultReturn: Int? = nil) -> Int?{
        
        guard let string = attemptParseToString(anyobject) else {
            return defaultReturn
        }
        return Int(string) ?? defaultReturn
    }
    
    internal class var null:NSNull { return NSNull() }
 }

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "YES", "yes", "1":
            return true
        case "False", "false", "NO", "no", "0":
            return false
        default:
            return nil
        }
    }
}

extension String {
    
    var numberValue:NSNumber? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: self)
    }
}


