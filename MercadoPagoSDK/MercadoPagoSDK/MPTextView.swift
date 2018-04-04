//
//  MPTextView.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 12/4/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class MPTextView: UITextView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
            }

    func addCharactersSpacing(_ spacing: CGFloat) {
        let attributedString = NSMutableAttributedString()
        if self.attributedText != nil {
            attributedString.append(self.attributedText!)
        }
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSMakeRange(0, self.attributedText!.length))
        self.attributedText = attributedString
    }

    func addLineSpacing(_ lineSpacing: Float) {

        let attributedString = NSMutableAttributedString()
        if self.attributedText != nil {
            attributedString.append(self.attributedText!)
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = CGFloat(lineSpacing)
        paragraphStyle.alignment = .center
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString

    }
}
