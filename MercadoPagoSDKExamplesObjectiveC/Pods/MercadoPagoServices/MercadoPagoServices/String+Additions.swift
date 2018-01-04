//
//  String+Additions.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 29/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

extension String {

    static let NON_BREAKING_LINE_SPACE = "\u{00a0}"

    public func startsWith(_ prefix: String) -> Bool {
        if prefix == self {
            return true
        }
        let startIndex = self.range(of: prefix)
        if startIndex == nil  || self.startIndex != startIndex?.lowerBound {
            return false
        }
        return true
    }

    subscript (i: Int) -> String {

        if self.characters.count > i {
            return String(self[self.characters.index(self.startIndex, offsetBy: i)])
        }

        return ""
    }

    public func lastCharacters(number: Int) -> String {
        let trimmedString: String = (self as NSString).substring(from: max(self.characters.count - number, 0))
        return trimmedString
    }

    public func indexAt(_ theInt: Int)->String.Index {

        return self.characters.index(self.characters.startIndex, offsetBy: theInt)
    }

    public func trimSpaces() -> String {

        var stringTrimmed = self.replacingOccurrences(of: " ", with: "")
        stringTrimmed = stringTrimmed.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return stringTrimmed
    }

    mutating func paramsAppend(key: String, value: String?) {
        if !key.isEmpty && !String.isNullOrEmpty(value) {
            if self.isEmpty {
                self = key + "=" + value!
            } else {
                self = self + "&" + key + "=" + value!
            }
        }
    }

    static public func getDate(_ string: String?) -> Date? {
        guard let dateString = string else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter.date(from: dateString)
    }
}

open class Regex {
    let internalExpression: NSRegularExpression?
    let pattern: String

    public init(_ pattern: String) {
        self.pattern = pattern
        do {
            self.internalExpression = try NSRegularExpression(pattern: pattern, options: [NSRegularExpression.Options.caseInsensitive])
        } catch {
            self.internalExpression = nil
        }
    }

    open func test(_ input: String) -> Bool {
        if self.internalExpression != nil {
            let matches = self.internalExpression!.matches(in: input, options: [], range:NSMakeRange(0, input.characters.count))
            return matches.count > 0
        } else {
            return false
        }
    }
}

extension Array {

    static public func isNullOrEmpty(_ value: Array?) -> Bool {
        return value == nil || value?.count == 0
    }
}

class JSONHandler: NSObject {

    class func jsonCoding(_ jsonDictionary: [String: Any]) -> String {
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
}

extension NSDictionary {

    public func toJsonString() -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)

            if let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {
                return jsonString
            }
            return ""

        } catch {
            return error.localizedDescription
        }
    }
    public func parseToQuery() -> String {
        if !NSDictionary.isNullOrEmpty(self) {
            var parametersString = ""
            for (key, value) in self {
                if let key = key as? String,
                    let value = value as? String {
                    parametersString = parametersString + key + "=" + value + "&"
                }
            }
            parametersString = parametersString.substring(to: parametersString.index(before: parametersString.endIndex))
            return parametersString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        } else {
            return ""
        }
    }

    func parseToLiteral() -> [String: Any] {

        var anyDict = [String: Any]()

        for (key, value) in self {
            anyDict[key as! String] = value
        }
        return anyDict
    }
    static public func isNullOrEmpty(_ value: NSDictionary?) -> Bool {
        return value == nil || value?.count == 0
    }

}
