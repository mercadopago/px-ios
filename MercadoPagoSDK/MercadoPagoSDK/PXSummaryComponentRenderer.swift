//
//  PXSummaryRenderer.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 28/2/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

struct PXSummaryComponentRenderer {

    func render(_ summaryComponent: PXSummaryComponent) -> UIView {
        if summaryComponent.props.summaryViewModel.details.count > 1 || summaryComponent.props.paymentData.getNumberOfInstallments() > 1 {
            return buildFullSummary(props: summaryComponent.props)
        }
        return buildCompactSummary(props: summaryComponent.props)
    }
    
    func expressRender(_ summaryComponent: PXSummaryComponent) -> UIView {
        summaryComponent.props.setTopMargin(margin: PXLayout.S_MARGIN)
        summaryComponent.props.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
        if summaryComponent.props.summaryViewModel.details.count > 1 || summaryComponent.props.paymentData.getNumberOfInstallments() > 1 {
            return buildFullSummary(props: summaryComponent.props)
        }
        return buildCompactSummary(props: summaryComponent.props)
    }
}

extension PXSummaryComponentRenderer {

    fileprivate func buildFullSummary(props: PXSummaryComponentProps) -> UIView {
        let fullSummaryView = PXSummaryFullComponentView(width: props.width, summaryViewModel: props.summaryViewModel, paymentData: props.paymentData, totalAmount: props.totalAmount, backgroundColor: props.backgroundColor, customSummaryTitle: props.customTitle, topMargin: props.topMargin)
        PXLayout.setHeight(owner: fullSummaryView, height: fullSummaryView.getHeight()).isActive = true
        return fullSummaryView
    }

    fileprivate func buildCompactSummary(props: PXSummaryComponentProps) -> UIView {

        let compactView = PXSummaryCompactComponentView()
        let BASELINE_OFFSET: Int = 10

        compactView.backgroundColor = props.backgroundColor
        compactView.translatesAutoresizingMaskIntoConstraints = false

        let amountAttributeText = Utils.getAttributedAmount(props.totalAmount, currency: MercadoPagoContext.getCurrency(), color: props.textColor, fontSize: PXSummaryCompactComponentView.TITLE_FONT_SIZE, baselineOffset: BASELINE_OFFSET)

        let customTitleAttributeText = NSAttributedString(string: props.customTitle, attributes: [NSAttributedStringKey.font: Utils.getFont(size: PXSummaryCompactComponentView.CUSTOM_TITLE_FONT_SIZE)])

        let viewHeight = compactView.buildView(amountAttributeText: amountAttributeText, bottomCustomTitle: customTitleAttributeText, textColor: props.textColor, backgroundColor: props.backgroundColor)

        PXLayout.setHeight(owner: compactView, height: viewHeight).isActive = true

        return compactView
    }
}
