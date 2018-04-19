//
//  TextMaskFormater.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 8/16/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers
open class TextMaskFormater: NSObject {

    var mask: String!
    open var characterSpace: Character! = "X"
    open var emptyMaskElement: Character! = "•"
    var completeEmptySpaces: Bool = true
    var leftToRight: Bool = true
    var unmask : (( _ textToUnmask: String) -> String)?

    public init(mask: String!, completeEmptySpaces: Bool = true, leftToRight: Bool = true, completeEmptySpacesWith: Character? = "•") {
        super.init()
        self.mask = mask
        self.completeEmptySpaces = completeEmptySpaces
        self.leftToRight = leftToRight
        self.emptyMaskElement = completeEmptySpacesWith
    }
    open func textMasked(_ text: String!, remasked: Bool = false) -> String! {

        if remasked {
            return textMasked(textUnmasked(text))
        }
        if text.count == 0 {
            return self.emptyTextMasked()
        }
        return self.maskText(text)
    }

    open func textUnmasked(_ text: String!) -> String! {

        if unmask != nil {
            return unmask!(text)
        } else {
            let charset: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
            var ints: String = ""
            for char: Character in text {
                if charset.contains(char) {
                    ints.append(char)
                }
            }
            return ints
        }

    }
    fileprivate func emptyTextMasked() -> String! {
        if completeEmptySpaces {
            return (mask?.replacingOccurrences(of: String(characterSpace), with: String(emptyMaskElement)))!
        } else {
            return ""
        }

    }

    fileprivate func replaceEmpySpot(_ text: String!) -> String! {
        return (text.replacingOccurrences(of: String(characterSpace), with: String(emptyMaskElement)))
    }

    fileprivate func maskText(_ text: String!) -> String! {
        let maskArray = Array(mask)
        var textToMask = text
        if (!leftToRight)&&(completeEmptySpaces) {
            textToMask = completeWithEmptySpaces(text)
        }
        let textArray = Array(textToMask!)
        var resultString: String = ""
        var charText: Character! = textArray[0]
        var charMask: Character!
        if !self.completeEmptySpaces && (textToMask?.count == 0) {
            return ""
        }

        var indexMask = 0
        var indexText = 0
        while (indexMask < maskArray.count) && (self.completeEmptySpaces || (textArray.count>indexText)) {

             charMask = maskArray[indexMask]

            if textArray.count>indexText {
                charText = textArray[indexText]
            } else {
                charText = nil
            }

            if charText == nil {
                resultString.append(String(charMask))
                indexMask += 1
            } else if String(charMask) != String(characterSpace) {
                resultString.append(String(charMask))
                indexMask += 1
            } else {
                 resultString.append(String(charText))
                indexMask += 1
                indexText += 1
            }
        }

        return self.replaceEmpySpot(resultString)

    }

    fileprivate func completeWithEmptySpaces(_ text: String) -> String {
        let charset: Set<Character> = [characterSpace]
        var xs: String = ""
        for char: Character in mask {
            if charset.contains(char) {
                xs.append(char)
            }
        }
        var max = xs.count - text.count
        let x: Character = characterSpace
        if max < 0 {
           max = 0
        }
        return (String(repeating: String(x), count: max) + text)

    }

    fileprivate func stringByChoose(_ maskCharacter: Character, textCharacter: Character!) -> String {
        if textCharacter == nil {
            return String(maskCharacter)
        }
        if String(maskCharacter) != String(characterSpace) {
            return String(maskCharacter) + String(textCharacter)
        }
        return String(textCharacter)
    }

}

struct Number {
    static let formatterWithSepator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        return formatter
    }()
}
/*
extension Integer {
    var stringFormatedWithSepator: String {
        return Number.formatterWithSepator.string(from: NSNumber(hashValue)) ?? ""
    }
}
*/
