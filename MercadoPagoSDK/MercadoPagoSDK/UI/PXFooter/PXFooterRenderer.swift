//
//  FooterRenderer.swift
//  TestAutolayout
//
//  Created by Demian Tejo on 10/19/17.
//  Copyright © 2017 Demian Tejo. All rights reserved.
//

import UIKit
import AndesUI

final class PXFooterRenderer: NSObject {

    let BUTTON_HEIGHT: CGFloat = 50.0
    weak var termsDelegate: PXTermsAndConditionViewDelegate?

    init(termsDelegate: PXTermsAndConditionViewDelegate? = nil) {
        self.termsDelegate = termsDelegate
    }

    func render(_ footer: PXFooterComponent) -> PXFooterView {
        let fooView = PXFooterView()
        fooView.translatesAutoresizingMaskIntoConstraints = false
        fooView.backgroundColor = .white

        if let buttonAction = footer.props.buttonAction {
            let principalButton = self.buildAnimatedButton(with: buttonAction, color: footer.props.primaryColor)
            principalButton.add(for: .touchUpInside) {
                fooView.delegate?.didTapPrimaryAction()
            }

            principalButton.layer.shadowRadius = 4
            fooView.principalButton = principalButton
            fooView.principalButton?.animationDelegate = footer.props.animationDelegate
            fooView.addSubview(principalButton)

            var principalButtonTopConstraint: NSLayoutConstraint?
            if let termsInfo = footer.props.termsInfo, termsInfo.text.isNotEmpty {
                let termsView = PXTermsAndConditionView(termsDto: footer.props.termsInfo, delegate: termsDelegate)
                fooView.insertSubview(termsView, belowSubview: principalButton)
                NSLayoutConstraint.activate([
                    termsView.leadingAnchor.constraint(equalTo: fooView.leadingAnchor),
                    termsView.trailingAnchor.constraint(equalTo: fooView.trailingAnchor),
                    termsView.topAnchor.constraint(equalTo: fooView.topAnchor),
                    termsView.heightAnchor.constraint(equalToConstant: termsView.DEFAULT_CREDITS_HEIGHT)
                ])
                principalButtonTopConstraint = principalButton.topAnchor.constraint(equalTo: termsView.bottomAnchor, constant: PXLayout.S_MARGIN)
            } else {
                principalButtonTopConstraint = principalButton.topAnchor.constraint(equalTo: fooView.topAnchor, constant: PXLayout.S_MARGIN)
            }
            if let principalButtonTopConstraint = principalButtonTopConstraint {
                principalButtonTopConstraint.isActive = true
            }

            NSLayoutConstraint.activate([
                principalButton.leadingAnchor.constraint(equalTo: fooView.leadingAnchor, constant: PXLayout.S_MARGIN),
                principalButton.trailingAnchor.constraint(equalTo: fooView.trailingAnchor, constant: -PXLayout.S_MARGIN),
                principalButton.heightAnchor.constraint(equalToConstant: BUTTON_HEIGHT)
            ])
        }
        if let linkButton = buildLinkButton(props: footer.props) {
            fooView.linkButton = linkButton
            fooView.addSubview(linkButton)

            if fooView.subviews.count == 1 {
                PXLayout.pinTop(view: linkButton, to: fooView, withMargin: PXLayout.S_MARGIN).isActive = true
            } else {
                PXLayout.put(view: linkButton, onBottomOfLastViewOf: fooView, withMargin: PXLayout.XXS_MARGIN)?.isActive = true
            }

            NSLayoutConstraint.activate([
                linkButton.leadingAnchor.constraint(equalTo: fooView.leadingAnchor, constant: PXLayout.S_MARGIN),
                linkButton.trailingAnchor.constraint(equalTo: fooView.trailingAnchor, constant: -PXLayout.S_MARGIN),
                linkButton.heightAnchor.constraint(equalToConstant: BUTTON_HEIGHT)
            ])
        }
        if footer.props.pinLastSubviewToBottom { // Si hay al menos alguna vista dentro del footer, agrego un margen
            PXLayout.pinLastSubviewToBottom(view: fooView, withMargin: PXLayout.S_MARGIN)
        }
        return fooView
    }

    func buildAnimatedButton(with footerAction: PXAction, color: UIColor? = .pxBlueMp) -> PXAnimatedButton {
        let button = PXAnimatedButton(normalText: "Pagar".localized, loadingText: "Procesando tu pago".localized, retryText: "Reintentar".localized)
        button.backgroundColor = color
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(footerAction.label, for: .normal)
        button.layer.cornerRadius = 4
        button.add(for: .touchUpInside, footerAction.action)
        return button
    }

    func buildLinkButton(props: PXFooterProps) -> UIControl? {
        guard let linkAction = props.linkAction  else { return nil }

        let linkButton: UIControl
        if props.useAndesButtonForLinkAction {
            linkButton = AndesButton(text: linkAction.label, hierarchy: AndesButtonHierarchy.quiet, size: AndesButtonSize.large, icon: nil)
        } else {
            let secondaryButton = PXSecondaryButton()
            secondaryButton.buttonTitle = linkAction.label
            linkButton = secondaryButton
        }
        linkButton.add(for: .touchUpInside, linkAction.action)
        linkButton.translatesAutoresizingMaskIntoConstraints = false
        return linkButton
    }
}
