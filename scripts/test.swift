#!/usr/bin/swift

import Foundation

//let bundle = Bundle.main
//let path = bundle.path(forResource: "translations", ofType: "plist")
//print(bundle)

//let dict = NSDictionary(contentsOfFile: path!)

//print(dict)

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


//if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//
//    var fileURL = dir.appendingPathComponent(file)
//    let ur = URL(fileURLWithPath: "./MercadoPagoSDK/\(file)")
//    fileURL = ur
//    print(fileURL)
//
//    //writing
//    do {
//        try text.write(to: fileURL, atomically: false, encoding: .utf8)
//    }
//    catch {/* error handling here */}
//
//    //reading
//    do {
//        let text2 = try String(contentsOf: fileURL, encoding: .utf8)
//        print(text2)
//    }
//    catch {/* error handling here */}
//}

