//
//  File.swift
//  MercadoPagoSDKV4
//
//  Created by Eric Ertl on 31/07/2020.
//

import MLCardForm

struct PXCardFormFieldSetting {
    let lenght: Int?
    let title: String
}

struct PXCardSecurityCodeFormFieldProperty: MLCardFormFieldPropertyProtocol {
    let fieldSetting: PXCardFormFieldSetting?

    init(fieldSetting: PXCardFormFieldSetting? = nil) {
        self.fieldSetting = fieldSetting
    }

    func fieldId() -> String {
        return "securityCode"
    }

    func fieldTitle() -> String {
        if let title = fieldSetting?.title {
            return title
        }
        return ""
    }

    func minLenght() -> Int {
        if let lenght = fieldSetting?.lenght {
            return lenght
        }
        return 3
    }

    func maxLenght() -> Int {
        if let lenght = fieldSetting?.lenght {
            return lenght
        }
        return 4
    }

    func helpMessage() -> String? {
        return nil
    }

    func errorMessage() -> String? {
        return nil
    }

    func patternMask() -> String? {
        if let lenght = fieldSetting?.lenght {
            return String(repeating: "$", count: lenght)
        }
        return String(repeating: "$", count: 3)
    }

    func validationPattern() -> String? {
        return nil
    }

    func keyboardType() -> UIKeyboardType? {
        return .numberPad
    }

    func keyboardNextText() -> String? {
        return nil
    }

    func keyboardBackText() -> String? {
        return nil
    }

    func shouldShowKeyboardClearButton() -> Bool {
        return false
    }

    func shouldShowToolBar() -> Bool {
        return false
    }
}
