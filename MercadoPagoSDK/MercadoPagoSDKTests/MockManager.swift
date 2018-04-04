//
//  MockManager.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 3/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation

class MockManager: NSObject {

    internal class func getMockFor(_ name: String) -> NSDictionary? {
        let path = Bundle(for: MockManager.self).path(forResource: "MockedData", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        do {
            let mockObj = try MockManager.convertStringToDictionary(dictPM?.value(forKey: name) as! String)!
            return mockObj as NSDictionary?
        } catch {
        }
        return nil
    }

    internal class func getDictionaryFor(string: String) -> NSDictionary? {
        do {
            let mockObj = try MockManager.convertStringToDictionary(string)!
            return mockObj as NSDictionary?
        } catch {
        }
        return nil
    }

    internal class func getMockResponseFor(_ uri: String, method: String) throws ->AnyObject? {
        let path = Bundle(for: MockManager.self).path(forResource: "MockedResponse", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        let valueOfKey = dictPM?.value(forKey: method + uri) as! String
        if let data = valueOfKey.data(using: String.Encoding.utf8) {
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            return json
        }
        return nil

    }

    internal class func convertStringToDictionary(_ text: String) throws -> [String: AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject]
            return json
        }
        return nil
    }

    internal class func convertArrayToDictionary(_ text: String) throws -> NSDictionary? {
        if let data = text.data(using: String.Encoding.utf8) {
            let jsonArr = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary
            return jsonArr
        }
        return nil
    }

}
