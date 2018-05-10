//
//  PXBankDealComponentRenderer.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 23/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PXBankDealComponentRenderer: NSObject {

    var IMAGE_VIEW_HEIGHT: CGFloat = 40

    func render(_ component: PXBankDealComponent) -> PXBankDealComponentView {
        let bankDealComponentView = PXBankDealComponentView()
        bankDealComponentView.translatesAutoresizingMaskIntoConstraints = false
        bankDealComponentView.backgroundColor = .white

        //Placeholder Label
        let placeholderLabel = getPlaceholderLabel(with: component.props.placeholder)

        //Image View
        if let imageUrl = component.props.imageUrl {
            let contentView = UIView()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            bankDealComponentView.imageView = contentView
            bankDealComponentView.addSubview(contentView)
            PXLayout.pinTop(view: contentView, withMargin: PXLayout.XS_MARGIN).isActive = true
            PXLayout.centerHorizontally(view: contentView).isActive = true
            PXLayout.setHeight(owner: contentView, height: IMAGE_VIEW_HEIGHT).isActive = true
            PXLayout.pinLeft(view: contentView).isActive = true
            PXLayout.pinRight(view: contentView).isActive = true

            Utils().loadImageFromURLWithCache(withUrl: imageUrl, targetView: contentView, placeholderView: placeholderLabel, fallbackView: placeholderLabel)
        } else {
            bankDealComponentView.addSubview(placeholderLabel)
            PXLayout.pinTop(view: placeholderLabel, withMargin: PXLayout.XS_MARGIN).isActive = true
            PXLayout.centerHorizontally(view: placeholderLabel).isActive = true
            PXLayout.setHeight(owner: placeholderLabel, height: IMAGE_VIEW_HEIGHT).isActive = true
            PXLayout.pinLeft(view: placeholderLabel, withMargin: 0).isActive = true
            PXLayout.pinRight(view: placeholderLabel, withMargin: 0).isActive = true
        }

        //Title Label
        let title = component.props.title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bankDealComponentView.titleLabel = titleLabel
        titleLabel.font = Utils.getFont(size: PXLayout.XS_FONT)
        titleLabel.text = title
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.UIColorFromRGB(0x232323)
        bankDealComponentView.addSubviewToBottom(titleLabel, withMargin: PXLayout.XS_MARGIN)
        PXLayout.matchWidth(ofView: titleLabel).isActive = true
        PXLayout.centerHorizontally(view: titleLabel).isActive = true

        //Subtitle Label
        if let subtitle = component.props.subtitle {
            let subtitleLabel = UILabel()
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            bankDealComponentView.subtitleLabel = subtitleLabel
            subtitleLabel.font = Utils.getFont(size: PXLayout.XXS_FONT)
            subtitleLabel.text = subtitle
            subtitleLabel.textColor = UIColor.UIColorFromRGB(0x999999)
            bankDealComponentView.addSubview(subtitleLabel)
            PXLayout.put(view: subtitleLabel, onBottomOf: titleLabel, withMargin: PXLayout.XXXS_MARGIN).isActive = true
            PXLayout.centerHorizontally(view: subtitleLabel).isActive = true
        }

        PXLayout.pinLastSubviewToBottom(view: bankDealComponentView, withMargin: PXLayout.XS_MARGIN)?.isActive = true
        return bankDealComponentView
    }

    func getPlaceholderLabel(with text: String?) -> UILabel {
        let placeholderLabel = UILabel()
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.font = Utils.getFont(size: PXLayout.XS_FONT)
        placeholderLabel.textColor = UIColor.UIColorFromRGB(0x999999)
        placeholderLabel.numberOfLines = 2
        placeholderLabel.lineBreakMode = .byTruncatingTail
        placeholderLabel.textAlignment = .center
        placeholderLabel.text = text
        return placeholderLabel
    }

}

class PXBankDealComponentView: PXComponentView {
    var imageView: UIView!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
}
