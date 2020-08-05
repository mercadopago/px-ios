//
//  PXCFTComponentView.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 7/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

final class PXCFTComponentView: PXComponentView {

    fileprivate lazy var VIEW_HEIGHT: CGFloat = 44
    fileprivate lazy var MATCH_WIDTH_PERCENT: CGFloat = 95
    fileprivate let cftLabel = UILabel()

    init(withCFTValue: PXText?) {
        super.init()
        backgroundColor = ThemeManager.shared.highlightBackgroundColor()

        if let cftText = withCFTValue {
            cftLabel.translatesAutoresizingMaskIntoConstraints = false
            cftLabel.textAlignment = .center
            cftLabel.numberOfLines = 1
            cftLabel.attributedText = cftText.getAttributedString(fontSize: PXLayout.M_FONT)
            cftLabel.accessibilityIdentifier = "CFT_label"
            addSubview(cftLabel)
            PXLayout.pinTop(view: cftLabel, to: self).isActive = true
            PXLayout.centerHorizontally(view: cftLabel).isActive = true
            PXLayout.matchWidth(ofView: cftLabel, toView: self, withPercentage: MATCH_WIDTH_PERCENT).isActive = true
            PXLayout.setHeight(owner: self, height: VIEW_HEIGHT).isActive = true
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
