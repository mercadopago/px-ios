//
//  PXPaymentMethodComponentRenderer.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 24/11/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class PXPaymentMethodComponentRenderer: NSObject {
    //Image
    let IMAGE_WIDTH: CGFloat = 48.0
    let IMAGE_HEIGHT: CGFloat = 48.0

    let TITLE_FONT_SIZE: CGFloat = 21.0
    let DETAIL_FONT_SIZE: CGFloat = 16.0
    let PM_DETAIL_FONT_SIZE: CGFloat = 14.0
    let DISCLAIMER_FONT_SIZE: CGFloat = 12.0

    func render(component: PXPaymentMethodComponent) -> PXPaymentMethodView {
        let pmBodyView = PXPaymentMethodView()
        pmBodyView.translatesAutoresizingMaskIntoConstraints = false
        let paymentMethodIcon = component.getPaymentMethodIconComponent()
        pmBodyView.paymentMethodIcon = paymentMethodIcon.render()
        pmBodyView.paymentMethodIcon!.layer.cornerRadius = IMAGE_WIDTH/2
        pmBodyView.addSubview(pmBodyView.paymentMethodIcon!)
        PXLayout.centerHorizontally(view: pmBodyView.paymentMethodIcon!).isActive = true
        PXLayout.setHeight(owner: pmBodyView.paymentMethodIcon!, height: IMAGE_HEIGHT).isActive = true
        PXLayout.setWidth(owner: pmBodyView.paymentMethodIcon!, width: IMAGE_WIDTH).isActive = true
        PXLayout.pinTop(view: pmBodyView.paymentMethodIcon!, withMargin: PXLayout.L_MARGIN).isActive = true

        // Title
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        pmBodyView.amountTitle = title
        pmBodyView.addSubview(title)
        title.text = component.props.amountTitle
        title.font = Utils.getFont(size: TITLE_FONT_SIZE)
        title.textColor = .pxBlack
        title.textAlignment = .center
        pmBodyView.putOnBottomOfLastView(view: title, withMargin: PXLayout.S_MARGIN)?.isActive = true
        PXLayout.pinLeft(view: title, withMargin: PXLayout.S_MARGIN).isActive = true
        PXLayout.pinRight(view: title, withMargin: PXLayout.S_MARGIN).isActive = true

        if let detailText = component.props.amountDetail {
            let detailLabel = UILabel()
            detailLabel.translatesAutoresizingMaskIntoConstraints = false
            pmBodyView.addSubview(detailLabel)
            pmBodyView.amountDetail = detailLabel
            detailLabel.text = detailText
            detailLabel.font = Utils.getFont(size: DETAIL_FONT_SIZE)
            detailLabel.textColor = .pxBrownishGray
            detailLabel.textAlignment = .center
            PXLayout.setHeight(owner: detailLabel, height: 18.0).isActive = true
            pmBodyView.putOnBottomOfLastView(view: detailLabel, withMargin: PXLayout.XXS_MARGIN)?.isActive = true
            PXLayout.pinLeft(view: detailLabel, withMargin: PXLayout.XXS_MARGIN).isActive = true
            PXLayout.pinRight(view: detailLabel, withMargin: PXLayout.XXS_MARGIN).isActive = true
        }

        if let paymentMethodDescription = component.props.paymentMethodDescription {
            let descriptionLabel = UILabel()
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            pmBodyView.addSubview(descriptionLabel)
            pmBodyView.paymentMethodDescription = descriptionLabel
            descriptionLabel.text = paymentMethodDescription
            descriptionLabel.font = Utils.getFont(size: DETAIL_FONT_SIZE)
            descriptionLabel.textColor = .pxBrownishGray
            descriptionLabel.textAlignment = .center
            pmBodyView.putOnBottomOfLastView(view: descriptionLabel, withMargin: PXLayout.XS_MARGIN)?.isActive = true
            PXLayout.pinLeft(view: descriptionLabel, withMargin: PXLayout.XS_MARGIN).isActive = true
            PXLayout.pinRight(view: descriptionLabel, withMargin: PXLayout.XS_MARGIN).isActive = true
        }

        if let pmDetailText = component.props.paymentMethodDetail {
            let pmDetailLabel = UILabel()
            pmDetailLabel.translatesAutoresizingMaskIntoConstraints = false
            pmBodyView.paymentMethodDetail = pmDetailLabel
            pmBodyView.addSubview(pmDetailLabel)
            pmDetailLabel.text = pmDetailText
            pmDetailLabel.font = Utils.getFont(size: PM_DETAIL_FONT_SIZE)
            pmDetailLabel.textColor = .pxBrownishGray
            pmDetailLabel.textAlignment = .center
            pmBodyView.putOnBottomOfLastView(view: pmDetailLabel, withMargin: PXLayout.XXS_MARGIN)?.isActive = true
            PXLayout.pinLeft(view: pmDetailLabel, withMargin:  PXLayout.XXS_MARGIN).isActive = true
            PXLayout.pinRight(view: pmDetailLabel, withMargin:  PXLayout.XXS_MARGIN).isActive = true
        }

        if let disclaimer = component.props.disclaimer {
            let disclaimerLabel = UILabel()
            disclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
            pmBodyView.disclaimerLabel = disclaimerLabel
            pmBodyView.addSubview(disclaimerLabel)
            disclaimerLabel.text = disclaimer
            disclaimerLabel.numberOfLines = 2
            disclaimerLabel.font = Utils.getFont(size: DISCLAIMER_FONT_SIZE)
            disclaimerLabel.textColor = .pxBrownishGray
            disclaimerLabel.textAlignment = .center
            pmBodyView.putOnBottomOfLastView(view: disclaimerLabel, withMargin: PXLayout.M_MARGIN)?.isActive = true
            PXLayout.pinLeft(view: disclaimerLabel, withMargin:  PXLayout.XS_MARGIN).isActive = true
            PXLayout.pinRight(view: disclaimerLabel, withMargin:  PXLayout.XS_MARGIN).isActive = true
        }
        pmBodyView.pinLastSubviewToBottom(withMargin: PXLayout.L_MARGIN)?.isActive = true

        return pmBodyView
    }
}

class PXPaymentMethodView: PXBodyView {
    var paymentMethodIcon: UIView?
    var amountTitle: UILabel?
    var amountDetail: UILabel?
    var paymentMethodDescription: UILabel?
    var paymentMethodDetail: UILabel?
    var disclaimerLabel: UILabel?
}
