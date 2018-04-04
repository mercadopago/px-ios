//
//  PXInstructionsActionRenderer.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 11/16/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

class PXInstructionsActionRenderer: NSObject {
    let CONTENT_WIDTH_PERCENT: CGFloat = 100.0
    let ACTION_LABEL_FONT_SIZE: CGFloat = PXLayout.XS_FONT
    let ACTION_LABEL_FONT_COLOR: UIColor = .px_blueMercadoPago()

    func render(_ instructionsAction: PXInstructionsActionComponent) -> PXInstructionsActionView {
        let instructionsActionView = PXInstructionsActionView()
        instructionsActionView.translatesAutoresizingMaskIntoConstraints = false
        instructionsActionView.backgroundColor = .pxLightGray

        guard let label = instructionsAction.props.instructionActionInfo?.label, instructionsAction.props.instructionActionInfo?.tag != nil, let url = instructionsAction.props.instructionActionInfo?.url else {
            return instructionsActionView
        }

        instructionsActionView.actionButton = buildActionButton(with: label, url: url, in: instructionsActionView)

        return instructionsActionView
    }

    func buildActionButton(with text: String, url: String, in superView: UIView) -> UIButton {
        let button = MPButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = Utils.getFont(size: ACTION_LABEL_FONT_SIZE)
        button.setTitleColor(ACTION_LABEL_FONT_COLOR, for: .normal)
        button.actionLink = url
        button.add(for: .touchUpInside) {
            if let URL = button.actionLink {
                self.goToURL(URL)
            }
        }
        superView.addSubview(button)

        let screenWidth = PXLayout.getScreenWidth(applyingMarginFactor: CONTENT_WIDTH_PERCENT)

        let height = UILabel.requiredHeight(forText: text, withFont: Utils.getFont(size: ACTION_LABEL_FONT_SIZE), inNumberOfLines: 0, inWidth: screenWidth)
        PXLayout.setHeight(owner: button, height: height).isActive = true
        PXLayout.matchWidth(ofView: button, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
        PXLayout.centerHorizontally(view: button).isActive = true
        PXLayout.pinTop(view: button).isActive = true
        PXLayout.pinBottom(view: button).isActive = true

        return button
    }

    func goToURL(_ url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.openURL(url)
        }
    }
}

class PXInstructionsActionView: PXComponentView {
    public var actionButton: UIButton?
}
