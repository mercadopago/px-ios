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

        //Image View
        if let image = component.props.image {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            bankDealComponentView.imageView = imageView
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            bankDealComponentView.addSubview(imageView)
            PXLayout.pinTop(view: imageView, withMargin: PXLayout.XS_MARGIN).isActive = true
            PXLayout.centerHorizontally(view: imageView).isActive = true
            PXLayout.setHeight(owner: imageView, height: IMAGE_VIEW_HEIGHT).isActive = true
            PXLayout.pinLeft(view: imageView, withMargin: 0).isActive = true
            PXLayout.pinRight(view: imageView, withMargin: 0).isActive = true
        } else if let placeholder = component.props.placeholder {
            let label = UILabel()
            label.font = Utils.getFont(size: PXLayout.XS_FONT)
            label.textColor = .red
            label.numberOfLines = 2
            label.lineBreakMode = .byTruncatingTail
            label.textAlignment = .center
            label.text = placeholder
            bankDealComponentView.addSubview(label)
            PXLayout.pinTop(view: label, withMargin: PXLayout.XS_MARGIN).isActive = true
            PXLayout.centerHorizontally(view: label).isActive = true
            PXLayout.setHeight(owner: label, height: IMAGE_VIEW_HEIGHT).isActive = true
            PXLayout.pinLeft(view: label, withMargin: 0).isActive = true
            PXLayout.pinRight(view: label, withMargin: 0).isActive = true
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

}

class PXBankDealComponentView: PXComponentView {
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
}
