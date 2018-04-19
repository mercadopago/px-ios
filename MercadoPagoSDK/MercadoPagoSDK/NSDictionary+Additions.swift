//
//  NSDictionary+Additions.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/25/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

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
                    parametersString += key + "=" + value + "&"
                }
            }
            let range = parametersString.index(before: parametersString.endIndex)
            parametersString = String(parametersString[..<range])
            return parametersString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        } else {
            return ""
        }
    }

    func parseToLiteral() -> [String: Any] {

        var anyDict = [String: Any]()

        for (key, value) in self {
            if let keyValue = key as? String {
                anyDict[keyValue] = value
            }
        }
        return anyDict
    }
    static public func isNullOrEmpty(_ value: NSDictionary?) -> Bool {
        return value == nil || value?.count == 0
    }

}
