//
//  PXOneTapSummaryRowRenderer.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 16/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

final class PXOneTapSummaryRowRenderer: PXXibRenderer {
    private var props: PXSummaryRowProps?
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var subtitleHeightConstraint: NSLayoutConstraint!

    init(withProps: PXSummaryRowProps) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        props = withProps
        loadXib(rendererComponentizableClass: self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// PXXibComponentizable renderer mandatory protocol.
extension PXOneTapSummaryRowRenderer {
    override func xibName() -> String {
        return "PXOneTapSummaryRowView"
    }

    override func containerView() -> UIView {
        return contentView
    }

    override func render() -> UIView {
        setupStyles()
        populateProps()
        return self
    }
}

extension PXOneTapSummaryRowRenderer {
    private func setupStyles() {
        contentView.backgroundColor = .clear
        titleLabel.textColor = ThemeManager.shared.labelTintColor()
        amountLabel.textColor = ThemeManager.shared.labelTintColor()
        subtitleLabel.textColor = ThemeManager.shared.greyColor()
        contentView.backgroundColor = props?.backgroundColor
    }

    private func populateProps() {
        if let componentProps = props {
            subtitleLabel.text = nil
            titleLabel.text = componentProps.title
            amountLabel.text = componentProps.rightText
            if let subTitleText = componentProps.subTitle {
                subtitleLabel.text = subTitleText
            } else {
                subtitleHeightConstraint.constant = 0
            }
        }
    }
}
