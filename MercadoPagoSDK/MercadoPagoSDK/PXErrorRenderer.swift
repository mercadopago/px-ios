//
//  PXErrorRenderer.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 12/4/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class PXErrorRenderer: NSObject {

    let CONTENT_WIDTH_PERCENT: CGFloat = 84.0
    let TITLE_FONT_SIZE: CGFloat = 20.0
    let DESCRIPTION_FONT_SIZE: CGFloat = 16.0
    let ACTION_FONT_SIZE: CGFloat = 18.0
    let ACTION_LABEL_FONT_COLOR: UIColor = .px_blueMercadoPago()

    func render(component: PXErrorComponent) -> PXErrorView {
        let errorBodyView = PXErrorView()
        errorBodyView.backgroundColor = .pxWhite
        errorBodyView.translatesAutoresizingMaskIntoConstraints = false

        //Title Label
        if component.hasTitle() {
            errorBodyView.titleLabel = buildTitleLabel(with: component.getTitle(), in: errorBodyView)
        }

        //Description Label
        errorBodyView.descriptionLabel = buildDescriptionLabel(with: component.getDescription(), in: errorBodyView, onBottomOf: errorBodyView.titleLabel)

        //Action Button
        if component.hasActionForCallForAuth() {
            errorBodyView.actionButton = buildActionButton(withTitle: component.getActionText(), in: errorBodyView, onBottomOf: errorBodyView.descriptionLabel, component: component)

            //Middle Divider
            errorBodyView.middleDivider = buildMiddleDivider(in: errorBodyView, onBottomOf: errorBodyView.actionButton)

            //Secondary Title Label
            errorBodyView.secondaryTitleLabel = buildSecondaryTitleLabel(with: component.getSecondaryTitleForCallForAuth(), in: errorBodyView, onBottomOf: errorBodyView.middleDivider)

            //Bottom Divider
            errorBodyView.bottomDivider = buildBottomDivider(in: errorBodyView, onBottomOf: errorBodyView.secondaryTitleLabel)
            errorBodyView.pinLastSubviewToBottom(withMargin: PXLayout.ZERO_MARGIN)?.isActive = true
        } else {
            errorBodyView.pinLastSubviewToBottom(withMargin: PXLayout.L_MARGIN)?.isActive = true
        }

        return errorBodyView
    }

    func buildTitleLabel(with text: String, in superView: UIView) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .pxBlack
        label.numberOfLines = 0

        let attributes = [ NSFontAttributeName: Utils.getFont(size: TITLE_FONT_SIZE) ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        label.attributedText = attributedString
        label.lineBreakMode = .byWordWrapping
        superView.addSubview(label)

        let screenWidth = PXLayout.getScreenWidth(applyingMarginFactor: CONTENT_WIDTH_PERCENT)

        let height = UILabel.requiredHeight(forAttributedText: attributedString, withFont: Utils.getFont(size: TITLE_FONT_SIZE), inWidth: screenWidth)
        PXLayout.setHeight(owner: label, height: height).isActive = true
        PXLayout.matchWidth(ofView: label, toView: superView, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
        PXLayout.centerHorizontally(view: label, to: superView).isActive = true
        PXLayout.pinTop(view: label, withMargin: PXLayout.L_MARGIN).isActive = true
        return label
    }

    func buildDescriptionLabel(with text: String, in superView: UIView, onBottomOf upperView: UIView?) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .pxBrownishGray
        label.numberOfLines = 0

        let attributes = [ NSFontAttributeName: Utils.getFont(size: DESCRIPTION_FONT_SIZE) ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        label.attributedText = attributedString

        label.lineBreakMode = .byWordWrapping
        superView.addSubview(label)

        let screenWidth = PXLayout.getScreenWidth(applyingMarginFactor: CONTENT_WIDTH_PERCENT)

        let height = UILabel.requiredHeight(forAttributedText: attributedString, withFont: Utils.getFont(size: DESCRIPTION_FONT_SIZE), inWidth: screenWidth)
        PXLayout.setHeight(owner: label, height: height).isActive = true
        PXLayout.matchWidth(ofView: label, toView: superView, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
        PXLayout.centerHorizontally(view: label, to: superView).isActive = true
        if let upperView = upperView {
            PXLayout.put(view: label, onBottomOf: upperView, withMargin: PXLayout.S_MARGIN).isActive = true
        } else {
            PXLayout.pinTop(view: label, withMargin: PXLayout.L_MARGIN).isActive = true
        }
        return label
    }

    func buildActionButton(withTitle text: String, in superView: UIView, onBottomOf upperView: UIView?, component: PXErrorComponent) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = Utils.getFont(size: ACTION_FONT_SIZE)
        button.setTitleColor(ACTION_LABEL_FONT_COLOR, for: .normal)
        button.add(for: .touchUpInside) {
            component.recoverPayment()
        }
        superView.addSubview(button)

        let screenWidth = PXLayout.getScreenWidth(applyingMarginFactor: CONTENT_WIDTH_PERCENT)

        let height = UILabel.requiredHeight(forText: text, withFont: Utils.getFont(size: ACTION_FONT_SIZE), inNumberOfLines: 0, inWidth: screenWidth)
        PXLayout.setHeight(owner: button, height: height).isActive = true
        PXLayout.matchWidth(ofView: button, toView: superView, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
        PXLayout.centerHorizontally(view: button, to: superView).isActive = true

        if let upperView = upperView {
            PXLayout.put(view: button, onBottomOf: upperView, withMargin: PXLayout.M_MARGIN).isActive = true
        }
        return button
    }

    func buildSecondaryTitleLabel(with text: String, in superView: UIView, onBottomOf upperView: UIView?) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .pxBlack
        label.numberOfLines = 0

        let attributes = [ NSFontAttributeName: Utils.getFont(size: TITLE_FONT_SIZE) ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        label.attributedText = attributedString

        label.lineBreakMode = .byWordWrapping
        superView.addSubview(label)

        let screenWidth = PXLayout.getScreenWidth(applyingMarginFactor: CONTENT_WIDTH_PERCENT)

        let height = UILabel.requiredHeight(forAttributedText: attributedString, withFont: Utils.getFont(size: TITLE_FONT_SIZE), inWidth: screenWidth)
        PXLayout.setHeight(owner: label, height: height).isActive = true
        PXLayout.matchWidth(ofView: label, toView: superView, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
        PXLayout.centerHorizontally(view: label, to: superView).isActive = true
        if let upperView = upperView {
            PXLayout.put(view: label, onBottomOf: upperView, withMargin: PXLayout.L_MARGIN).isActive = true
        }
        return label
    }

    func buildMiddleDivider(in superView: UIView, onBottomOf upperView: UIView?) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .pxMediumLightGray
        superView.addSubview(view)
        PXLayout.setHeight(owner: view, height: 1).isActive = true
        PXLayout.matchWidth(ofView: view, toView: superView).isActive = true
        PXLayout.centerHorizontally(view: view, to: superView).isActive = true

        if let upperView = upperView {
            PXLayout.put(view: view, onBottomOf:upperView, withMargin: PXLayout.XXL_MARGIN).isActive = true
        }
        return view
    }

    func buildBottomDivider(in superView: UIView, onBottomOf upperView: UIView?) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .pxMediumLightGray
        superView.addSubview(view)
        PXLayout.setHeight(owner: view, height: 1).isActive = true
        PXLayout.matchWidth(ofView: view, toView: superView).isActive = true
        PXLayout.centerHorizontally(view: view, to: superView).isActive = true

        if let upperView = upperView {
            PXLayout.put(view: view, onBottomOf:upperView, withMargin: PXLayout.L_MARGIN).isActive = true
        }
        return view
    }
}

class PXErrorView: PXBodyView {
    var titleLabel: UILabel?
    var descriptionLabel: UILabel?
    var actionButton: UIButton?
    var middleDivider: UIView?
    var secondaryTitleLabel: UILabel?
    var bottomDivider: UIView?
}
