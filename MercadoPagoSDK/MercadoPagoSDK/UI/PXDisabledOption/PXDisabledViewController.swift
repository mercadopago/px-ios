//
//  PXDisabledViewController.swift
//  FXBlurView
//
//  Created by Federico Bustos Fierro on 03/04/2019.
//

import UIKit

class PXDisabledViewController: UIViewController {

    init(isAccountMoney: Bool) {
        super.init(nibName: nil, bundle: nil)
        let title = UILabel()

        let amTitle = "disabled_title_am"
        let cardTitle = "disabled_title_card"
        let amDescription = "disabled_description_am"
        let cardDescription = "disabled_description_card"
        let buttonText = "px_dialog_detail_payment_method_disable_link"

        title.text = isAccountMoney ? amTitle.localized_beta : cardTitle.localized_beta
        view.addSubview(title)
        title.font = Utils.getFont(size: PXLayout.M_FONT)
        title.textColor = ThemeManager.shared.boldLabelTintColor()
        title.textAlignment = .center
        title.numberOfLines = 0
        _ = PXLayout.pinTop(view: title, to: view, withMargin: PXLayout.M_MARGIN)
        PXLayout.setHeight(owner: title, height: 50).isActive = true
        _ = PXLayout.pinLeft(view: title, to: view, withMargin: PXLayout.M_MARGIN).isActive = true
        _ = PXLayout.pinRight(view: title, to: view, withMargin: PXLayout.M_MARGIN).isActive = true

        let description = UILabel()
        description.text = isAccountMoney ? amDescription.localized_beta : cardDescription.localized_beta
        view.addSubview(description)
        description.font = Utils.getFont(size: PXLayout.XS_FONT)
        description.textColor = ThemeManager.shared.labelTintColor()
        description.textAlignment = .center
        description.numberOfLines = 0
        PXLayout.setHeight(owner: description, height: 50).isActive = true
        _ = PXLayout.put(view: description, onBottomOf: title, withMargin: PXLayout.S_MARGIN, relation: .equal).isActive = true
        _ = PXLayout.pinLeft(view: description, to: view, withMargin: PXLayout.S_MARGIN).isActive = true
        _ = PXLayout.pinRight(view: description, to: view, withMargin: PXLayout.S_MARGIN).isActive = true

        let dismissButton = PXSecondaryButton()
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.buttonTitle = buttonText.localized
        view.addSubview(dismissButton)
        _ = PXLayout.put(view: dismissButton, onBottomOf: description, withMargin: PXLayout.S_MARGIN, relation: .equal)
        _ = PXLayout.pinLeft(view: dismissButton, to: view, withMargin: PXLayout.S_MARGIN).isActive = true
        _ = PXLayout.pinRight(view: dismissButton, to: view, withMargin: PXLayout.S_MARGIN).isActive = true
        PXLayout.setHeight(owner: dismissButton, height: 48).isActive = true
        _ = PXLayout.pinBottom(view: dismissButton, to: view, withMargin: PXLayout.M_MARGIN)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
