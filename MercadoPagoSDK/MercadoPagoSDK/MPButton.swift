//
//  MPButton.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 3/28/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers
open class MPButton: UIButton {

    var actionLink: String?

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) {
        super.init(frame: frame)
        if self.titleLabel != nil {
            if self.titleLabel!.font != nil {
                self.titleLabel!.font = Utils.getFont(size: self.titleLabel!.font.pointSize)
            }
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _ = MercadoPagoUIViewController.loadFont(ThemeManager.shared.getFontName())
        if self.titleLabel != nil {
            if self.titleLabel!.font != nil {
                self.titleLabel!.font = Utils.getFont(size: self.titleLabel!.font.pointSize)
            }
        }
    }

}
