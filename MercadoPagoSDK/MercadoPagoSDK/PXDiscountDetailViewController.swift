//
//  PXDiscountDetailViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 28/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoServicesV4

final class PXDiscountDetailViewController: MercadoPagoUIViewController {

    override open var screenName: String { return "DISCOUNT_SUMMARY" }

    private var amountHelper: PXAmountHelper
    private let fontSize: CGFloat = PXLayout.S_FONT
    private let baselineOffSet: Int = 6
    private let fontColor = ThemeManager.shared.boldLabelTintColor()
    private let discountFontColor = ThemeManager.shared.noTaxAndDiscountLabelTintColor()
    private let shouldShowTitle: Bool
    private let currency = MercadoPagoContext.getCurrency()
    let contentView: PXComponentView = PXComponentView()

    init(amountHelper: PXAmountHelper, shouldShowTitle: Bool = false) {
        self.amountHelper = amountHelper
        self.shouldShowTitle = shouldShowTitle
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        if self.contentView.isEmpty() {
            renderViews()
        }
    }
}

// MARK: Getters
extension PXDiscountDetailViewController {
    func getContentView() -> PXComponentView {
        renderViews()
        return self.contentView
    }
}

// MARK: Render Views
extension PXDiscountDetailViewController {

    private func renderViews() {

        if shouldShowTitle {
            let headerText = getHeader()
            let headerView = UIView()
            headerView.translatesAutoresizingMaskIntoConstraints = false
            headerView.backgroundColor = UIColor.UIColorFromRGB(0xf5f5f5)
            self.contentView.addSubviewToBottom(headerView)
            PXLayout.setHeight(owner: headerView, height: 40).isActive = true
            PXLayout.pinLeft(view: headerView, withMargin: PXLayout.ZERO_MARGIN).isActive = true
            PXLayout.pinRight(view: headerView, withMargin: PXLayout.ZERO_MARGIN).isActive = true

            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.attributedText = headerText
            headerView.addSubview(label)
            PXLayout.setHeight(owner: label, height: 16).isActive = true
            PXLayout.centerVertically(view: label).isActive = true
            PXLayout.pinLeft(view: label, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.pinRight(view: label, withMargin: PXLayout.M_MARGIN).isActive = true
        }

        if let title = getTitle() {
            buildAndAddLabel(to: self.contentView, margin: PXLayout.M_MARGIN, with: title, height: 20, accessibilityIdentifier: "discount_detail_title_label")
        }

        if let disclaimer = getDisclaimer() {
            buildAndAddLabel(to: self.contentView, margin: PXLayout.XS_MARGIN, with: disclaimer, accessibilityIdentifier: "discount_detail_disclaimer_label")
        }

        if let description = getDescription() {
            buildAndAddLabel(to: self.contentView, margin: PXLayout.XXS_MARGIN, with: description, height: 34, accessibilityIdentifier: "discount_detail_description_label")
        }
        if !amountHelper.consumedDiscount {
            buildSeparatorLine(in: self.contentView, topMargin: PXLayout.M_MARGIN, sideMargin: PXLayout.M_MARGIN, height: 1)

        }
        if let footerMessage = getFooterMessage() {
            buildAndAddLabel(to: self.contentView, margin: PXLayout.S_MARGIN, with: footerMessage, accessibilityIdentifier: "discount_detail_footer_label")
        }

        self.contentView.pinLastSubviewToBottom(withMargin: PXLayout.M_MARGIN)?.isActive = true
        self.view.addSubview(contentView)
        PXLayout.matchWidth(ofView: contentView).isActive = true
        PXLayout.matchHeight(ofView: contentView).isActive = true
        PXLayout.centerHorizontally(view: contentView).isActive = true
        PXLayout.centerVertically(view: contentView).isActive = true
    }

    func buildAndAddLabel(to view: PXComponentView, margin: CGFloat, with text: NSAttributedString, height: CGFloat? = nil, accessibilityIdentifier: String) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.attributedText = text
        label.accessibilityIdentifier = accessibilityIdentifier
        view.addSubviewToBottom(label, withMargin: margin)
        if let height = height {
            PXLayout.setHeight(owner: label, height: height).isActive = true
        }
        PXLayout.pinLeft(view: label, withMargin: PXLayout.M_MARGIN).isActive = true
        PXLayout.pinRight(view: label, withMargin: PXLayout.M_MARGIN).isActive = true
    }

    func buildSeparatorLine(in view: PXComponentView, topMargin: CGFloat, sideMargin: CGFloat, height: CGFloat) {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviewToBottom(line, withMargin: topMargin)
        PXLayout.setHeight(owner: line, height: height).isActive = true
        PXLayout.pinLeft(view: line, withMargin: sideMargin).isActive = true
        PXLayout.pinRight(view: line, withMargin: sideMargin).isActive = true
        line.alpha = 0.6
        line.backgroundColor = ThemeManager.shared.greyColor()
    }

    func getHeader() -> NSAttributedString {
        let attributes = [NSAttributedStringKey.font: Utils.getLightFont(size: PXLayout.XXS_FONT), NSAttributedStringKey.foregroundColor: ThemeManager.shared.labelTintColor()]
        if amountHelper.consumedDiscount {
            return NSAttributedString(string: "modal_title_consumed_discount".PXLocalized, attributes: attributes)
        } else {
            return NSAttributedString(string: amountHelper.discount!.getDiscountDescription(), attributes: attributes)
        }
    }

    func getTitle() -> NSAttributedString? {
        if let maxCouponAmount = amountHelper.maxCouponAmount {
            let attributes = [NSAttributedStringKey.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT), NSAttributedStringKey.foregroundColor: ThemeManager.shared.boldLabelTintColor()]
            let amountAttributedString = Utils.getAttributedAmount(withAttributes: attributes, amount: maxCouponAmount, currency: currency, negativeAmount: false)
            let string: String = ("discount_detail_modal_disclaimer".PXLocalized as NSString).replacingOccurrences(of: "%1$s", with: amountAttributedString.string)
            let attributedString = NSMutableAttributedString(string: string, attributes: attributes)

            return attributedString
        }
        return nil
    }

    func getDisclaimer() -> NSAttributedString? {
        let attributes = [NSAttributedStringKey.font: Utils.getLightFont(size: PXLayout.XXS_FONT), NSAttributedStringKey.foregroundColor: ThemeManager.shared.greyColor()]
         if amountHelper.campaign?.maxRedeemPerUser == 1 {
            var message = "unique_discount_detail_modal_footer".PXLocalized
            if let expirationDate = amountHelper.campaign?.endDate {
                let messageDate = "discount_end_date".PXLocalized
                message.append(String.space())
                message.append(messageDate.replacingOccurrences(of: "%1s", with: Utils.getFormatedStringDate(expirationDate)))
            }
            return NSAttributedString(string: message, attributes: attributes)
         } else if let maxRedeemPerUser = amountHelper.campaign?.maxRedeemPerUser, maxRedeemPerUser > 1 {
            return NSAttributedString(string: "multiple_discount_detail_modal_footer".PXLocalized, attributes: attributes)
         } else if amountHelper.consumedDiscount {
            return NSAttributedString(string: "modal_content_consumed_discount".PXLocalized, attributes: attributes)
        }
        return nil
    }

    func getDescription() -> NSAttributedString? {
        //TODO: descuentos por medio de pago
        return nil
    }

    func getFooterMessage() -> NSAttributedString? {
        if amountHelper.consumedDiscount {
            return nil
        }
        let attributes = [NSAttributedStringKey.font: Utils.getLightFont(size: PXLayout.XXS_FONT), NSAttributedStringKey.foregroundColor: ThemeManager.shared.greyColor()]
        let string = NSAttributedString(string: "discount_detail_modal_footer".PXLocalized, attributes: attributes)
        return string
    }
}
