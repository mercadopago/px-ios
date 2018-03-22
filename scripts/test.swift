#!/usr/bin/swift

import Foundation

let translationsFile = "translations.plist"
let pxStringsFile = "PXStrings.swift"
var finalText = "import Foundation\n\nenum PXStr {"

//reading
do {
    let bundle = Bundle(path: "./MercadoPagoSDK/")
    if let path = bundle?.path(forResource: "translations", ofType: "plist"), let translationsDict = NSDictionary(contentsOfFile: path) {
        let keys = translationsDict.allKeys
        for key in keys {
            finalText += "\n    static let \(key) = \"\(key)\""
        }
        finalText += "\n}"
        
        do {
            let url = URL(fileURLWithPath: "./MercadoPagoSDK/\(pxStringsFile)")
            try finalText.write(to: url, atomically: false, encoding: .utf8)
        }
        catch {/* error handling here */}
    }
}
catch {}
