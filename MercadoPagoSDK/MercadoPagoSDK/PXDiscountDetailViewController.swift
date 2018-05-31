//
//  PXDiscountDetailViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 28/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

final class PXDiscountDetailViewController: MercadoPagoUIViewController {

    override open var screenName: String { return "DISCOUNT_SUMMARY" }

    private var discount: DiscountCoupon
    private let fontSize: CGFloat = 18.0
    private let baselineOffSet: Int = 6
    private let fontColor = ThemeManager.shared.boldLabelTintColor()
    private let discountFontColor = ThemeManager.shared.noTaxAndDiscountLabelTintColor()
    private let shouldShowTitle: Bool
    let contentView: PXComponentView = PXComponentView()

    init(discount: DiscountCoupon, shouldShowTitle: Bool = false) {
        self.discount = discount
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
            buildAndAddLabel(to: self.contentView, margin: PXLayout.M_MARGIN, with: title, height: 20)
        }

        if let disclaimer = getDisclaimer() {
            buildAndAddLabel(to: self.contentView, margin: PXLayout.XXS_MARGIN, with: disclaimer, height: 19)
        }

        if let description = getDescription() {
            buildAndAddLabel(to: self.contentView, margin: PXLayout.XXS_MARGIN, with: description, height: 34)
        }

        buildSeparatorLine(in: self.contentView, topMargin: PXLayout.M_MARGIN, sideMargin: PXLayout.M_MARGIN, height: 1)

        if let footerMessage = getFooterMessage() {
            buildAndAddLabel(to: self.contentView, margin: PXLayout.S_MARGIN, with: footerMessage)
        }

        self.contentView.pinLastSubviewToBottom(withMargin: PXLayout.M_MARGIN)?.isActive = true
        self.view.addSubview(contentView)
        PXLayout.matchWidth(ofView: contentView).isActive = true
        PXLayout.matchHeight(ofView: contentView).isActive = true
        PXLayout.centerHorizontally(view: contentView).isActive = true
        PXLayout.centerVertically(view: contentView).isActive = true
    }

    func buildAndAddLabel(to view: PXComponentView, margin: CGFloat, with text: NSAttributedString, height: CGFloat? = nil) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.attributedText = text
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
        line.backgroundColor = UIColor.UIColorFromRGB(0xEEEEEE)
    }

    func getHeader() -> NSAttributedString {
        let attributes = [NSAttributedStringKey.font: Utils.getLightFont(size: PXLayout.XXS_FONT), NSAttributedStringKey.foregroundColor: UIColor.UIColorFromRGB(0x666666)]
        let string = NSAttributedString(string: "Descuento", attributes: attributes)
        return string
    }

    func getTitle() -> NSAttributedString? {
        let activeDiscountAttributes = [NSAttributedStringKey.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT), NSAttributedStringKey.foregroundColor: UIColor.UIColorFromRGB(0x333333)]
        if discount.amount_off != "0" {
            let string = NSMutableAttributedString(string: "- $ ", attributes: activeDiscountAttributes)
            string.append(NSAttributedString(string: discount.amount_off, attributes: activeDiscountAttributes))
            string.append(NSAttributedString(string: " OFF", attributes: activeDiscountAttributes))
            return string
        } else if discount.percent_off != "0" {
            let string = NSMutableAttributedString(string: "", attributes: activeDiscountAttributes)
            string.append(NSAttributedString(string: discount.percent_off, attributes: activeDiscountAttributes))
            string.append(NSAttributedString(string: "% OFF", attributes: activeDiscountAttributes))
            return string
        }
        return nil
    }

    func getDisclaimer() -> NSAttributedString? {
        //TOOD: agregar logica de tope de descuento
        let attributes = [NSAttributedStringKey.font: Utils.getLightFont(size: PXLayout.XXS_FONT), NSAttributedStringKey.foregroundColor: UIColor.UIColorFromRGB(0x999999)]
        let string = NSAttributedString(string: "con tope de descuento", attributes: attributes)
        return string
    }

    func getDescription() -> NSAttributedString? {
        //TODO: descuentos por medio de pago
        return nil
    }

    func getFooterMessage() -> NSAttributedString? {
        let attributes = [NSAttributedStringKey.font: Utils.getLightFont(size: PXLayout.XXS_FONT), NSAttributedStringKey.foregroundColor: UIColor.UIColorFromRGB(0x999999)]
        let string = NSAttributedString(string: "Aplicamos el mejor descuento disponible", attributes: attributes)
        return string
    }
}
