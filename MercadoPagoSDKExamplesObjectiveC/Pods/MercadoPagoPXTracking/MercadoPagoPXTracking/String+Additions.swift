//
//  String+Additions.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 29/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

extension String {

    static public func isNullOrEmpty(_ value: String?) -> Bool {
        return value == nil || value!.isEmpty
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

    public func trimSpaces() -> String {

        var stringTrimmed = self.replacingOccurrences(of: " ", with: "")
        stringTrimmed = stringTrimmed.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return stringTrimmed
    }
}
