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

    static public func isNullOrEmpty(_ value: String?) -> Bool {
        return value == nil || value!.isEmpty
    }

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
