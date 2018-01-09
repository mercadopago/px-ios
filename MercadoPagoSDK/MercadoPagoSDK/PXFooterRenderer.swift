//
//  FooterRenderer.swift
//  TestAutolayout
//
//  Created by Demian Tejo on 10/19/17.
//  Copyright © 2017 Demian Tejo. All rights reserved.
//

import UIKit

class PXFooterRenderer: NSObject {

    let BUTTON_HEIGHT: CGFloat = 50.0

    func render(_ footer: PXFooterComponent) -> PXFooterView {
        let fooView = PXFooterView()
        var topView: UIView = fooView
        fooView.translatesAutoresizingMaskIntoConstraints = false
        fooView.backgroundColor = .pxWhite
        if let principalAction = footer.props.buttonAction {
            let principalButton = self.buildPrincipalButton(with: principalAction, color: footer.props.primaryColor)
            fooView.principalButton = principalButton
            fooView.addSubview(principalButton)
            PXLayout.pinTop(view: principalButton, to: topView, withMargin: PXLayout.S_MARGIN).isActive = true
            PXLayout.pinLeft(view: principalButton, to: fooView, withMargin: PXLayout.S_MARGIN).isActive = true
            PXLayout.pinRight(view: principalButton, to: fooView, withMargin: PXLayout.S_MARGIN).isActive = true
            PXLayout.setHeight(owner: principalButton, height: BUTTON_HEIGHT).isActive = true
            topView = principalButton
        }
        if let linkAction = footer.props.linkAction {

            let linkButton = self.buildLinkButton(with: linkAction, color: footer.props.primaryColor)

            fooView.linkButton = linkButton
            fooView.addSubview(linkButton)
            if topView != fooView {
               PXLayout.put(view: linkButton, onBottomOf: topView, withMargin: PXLayout.S_MARGIN).isActive = true
            } else {
                PXLayout.pinTop(view: linkButton, to: fooView, withMargin: PXLayout.S_MARGIN).isActive = true
            }

            PXLayout.pinLeft(view: linkButton, to: fooView, withMargin: PXLayout.S_MARGIN).isActive = true
            PXLayout.pinRight(view: linkButton, to: fooView, withMargin: PXLayout.S_MARGIN).isActive = true
            PXLayout.setHeight(owner: linkButton, height: BUTTON_HEIGHT).isActive = true
            topView = linkButton
        }
        if topView != fooView { // Si hay al menos alguna vista dentro del footer, agrego un margen
            PXLayout.pinBottom(view: topView, to: fooView, withMargin: PXLayout.S_MARGIN).isActive = true
        }
        return fooView
    }
    func buildPrincipalButton(with footerAction: PXFooterAction, color: UIColor? = .pxBlueMp) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 3
        button.setTitle(footerAction.label, for: .normal)
        button.backgroundColor = color
        button.add(for: .touchUpInside, footerAction.action)
        return button
    }
    func buildLinkButton(with footerAction: PXFooterAction, color: UIColor? = .pxBlueMp) -> UIButton {
        let linkButton = UIButton()
        linkButton.translatesAutoresizingMaskIntoConstraints = false
        linkButton.setTitle(footerAction.label, for: .normal)
        linkButton.setTitleColor(color, for: .normal)
        linkButton.backgroundColor = UIColor(white: 1, alpha: 0)
        linkButton.add(for: .touchUpInside, footerAction.action)
        return linkButton
    }
}

class PXFooterView: UIView {
    public var principalButton: UIButton?
    public var linkButton: UIButton?
}
