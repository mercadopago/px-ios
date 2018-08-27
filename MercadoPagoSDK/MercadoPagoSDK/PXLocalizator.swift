//
//  PXLocalizator.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 2/8/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

private class PXLocalizator {
    static let sharedInstance = PXLocalizator()

    lazy var localizableDictionary: NSDictionary! = {
        let bundle = MercadoPago.getBundle()

        if let path = bundle?.path(forResource: "PXTranslations", ofType: "plist") {
            return NSDictionary(contentsOfFile: path)
        }
        fatalError("Localizable file NOT found")
    }()

    func localize(string: String) -> String {
        let languageID = MercadoPagoContext.getLanguage()
        let parentlanguageID = MercadoPagoContext.getParentLanguageID()

        let localizedStringDictionary = localizableDictionary.value(forKey: string) as? NSDictionary

        guard localizedStringDictionary != nil, let localizedString = localizedStringDictionary?.value(forKey: languageID) as? String else {

            if let parentLocalizedString = localizedStringDictionary?.value(forKey: parentlanguageID) as? String {
                return parentLocalizedString
            }

            #if DEBUG
                assertionFailure("Missing translation for: \(string)")
            #endif

            return string
        }

        return localizedString
    }
}

extension String {
    var PXLocalized: String {
        return PXLocalizator.sharedInstance.localize(string: self)
    }
}
