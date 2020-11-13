//
//  PXFooterProps.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 16/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

final class PXFooterProps: NSObject {
    var buttonAction: PXAction?
    var linkAction: PXAction?
    var useAndesButtonForLinkAction: Bool
    var primaryColor: UIColor?
    weak var animationDelegate: PXAnimatedButtonDelegate?
    var pinLastSubviewToBottom: Bool
    var termsInfo: PXTermsDto?
    var andesButtonConfig: PXAndesButtonConfig

    init(buttonAction: PXAction? = nil, linkAction: PXAction? = nil, useAndesButtonForLinkAction: Bool = false, primaryColor: UIColor? = ThemeManager.shared.getAccentColor(), animationDelegate: PXAnimatedButtonDelegate? = nil, pinLastSubviewToBottom: Bool = true, termsInfo: PXTermsDto? = nil, andesButtonConfig: PXAndesButtonConfig = PXAndesButtonConfig()) {
        self.buttonAction = buttonAction
        self.linkAction = linkAction
        self.useAndesButtonForLinkAction = useAndesButtonForLinkAction
        self.primaryColor = primaryColor
        self.animationDelegate = animationDelegate
        self.pinLastSubviewToBottom = pinLastSubviewToBottom
        self.termsInfo = termsInfo
        self.andesButtonConfig = andesButtonConfig
    }
}
