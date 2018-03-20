//
//  PaymentMethodCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 29/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class OfflinePaymentMethodCell: UITableViewCell {

    static let ROW_HEIGHT = CGFloat(313)

    @IBOutlet weak var iconCash: UIImageView!
    @IBOutlet weak var paymentMethodDescription: MPLabel!
    @IBOutlet weak var acreditationTimeLabel: MPLabel!

    @IBOutlet weak var changePaymentButton: PXSecondaryButton!

    @IBOutlet weak var accreditationTimeIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        var image = MercadoPago.getImage("time")
        image = image?.withRenderingMode(.alwaysTemplate)
        self.accreditationTimeIcon.tintColor = ThemeManager.shared.getTheme().labelTintColor()
        self.accreditationTimeIcon.image = image
        self.iconCash.image = MercadoPago.getOfflineReviewAndConfirmImage()
        self.contentView.backgroundColor = ThemeManager.shared.getTheme().detailedBackgroundColor()
    }

    override func prepareForReuse() {
        self.changePaymentButton.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    fileprivate func setTitle(_ paymentMethodOption: PaymentMethodOption, _ attributedTitle: NSMutableAttributedString) {
        var currentTitle = ""
        let titleI18N = "ryc_title_" + paymentMethodOption.getId()
        if titleI18N.existsLocalized() {
            currentTitle = titleI18N.localized_temp
        } else {
            currentTitle = "ryc_title_default".localized_temp
        }

        attributedTitle.append(NSAttributedString(string : currentTitle, attributes: [NSFontAttributeName: Utils.getFont(size: 20), NSForegroundColorAttributeName: ThemeManager.shared.getTheme().boldLabelTintColor()]))

        let complementaryTitle = "ryc_complementary_" + paymentMethodOption.getId()
        if complementaryTitle.existsLocalized() {
            attributedTitle.append(NSAttributedString(string : complementaryTitle.localized_temp, attributes: [NSFontAttributeName: Utils.getFont(size: 20), NSForegroundColorAttributeName: ThemeManager.shared.getTheme().boldLabelTintColor()]))
        }
        var paymentMethodName = "ryc_payment_method_" + paymentMethodOption.getId()

        if paymentMethodName.existsLocalized() {
            paymentMethodName = paymentMethodName.localized_temp
        } else {
            paymentMethodName = paymentMethodOption.getDescription()
        }

        attributedTitle.append(NSAttributedString(string : paymentMethodName, attributes: [NSFontAttributeName: Utils.getFont(size: 20), NSForegroundColorAttributeName: ThemeManager.shared.getTheme().boldLabelTintColor()]))
    }

    internal func fillCell(_ paymentMethodOption: PaymentMethodOption, amount: Double, paymentMethod: PaymentMethod, currency: Currency, reviewScreenPreference: ReviewScreenPreference = ReviewScreenPreference()) {

        let attributedAmount = Utils.getAttributedAmount(amount, currency: currency, color : UIColor.black)
        var attributedTitle = NSMutableAttributedString(string : "Pagarás ".localized_temp, attributes: [NSFontAttributeName: Utils.getFont(size: 20), NSForegroundColorAttributeName: ThemeManager.shared.getTheme().boldLabelTintColor()])
        attributedTitle.append(attributedAmount)

        if paymentMethodOption.getId() == PaymentTypeId.ACCOUNT_MONEY.rawValue && paymentMethod.paymentTypeId != PaymentTypeId.PAYMENT_METHOD_PLUGIN.rawValue {
            attributedTitle = NSMutableAttributedString(string : "Con dinero en cuenta".localized_temp, attributes: [NSFontAttributeName: Utils.getFont(size: 20), NSForegroundColorAttributeName: ThemeManager.shared.getTheme().boldLabelTintColor()])
            self.iconCash.image = MercadoPago.getOfflineReviewAndConfirmImage(paymentMethod)
            self.acreditationTimeLabel.isHidden = true
            self.accreditationTimeIcon.isHidden = true

        } else if let paymentMethodPlugin =  paymentMethodOption as? PXPaymentMethodPlugin {

            let props = PXPaymentMethodIconProps(paymentMethodIcon: paymentMethodPlugin.getImage())
            let component = PXPaymentMethodIconComponent(props: props)
            let view = component.render()
            self.addSubview(view)
            PXLayout.matchWidth(ofView: view, toView: self.iconCash).isActive = true
            PXLayout.matchHeight(ofView: view, toView: self.iconCash).isActive = true
            PXLayout.centerHorizontally(view: view, to: self.iconCash).isActive = true
            PXLayout.centerVertically(view: view, to: self.iconCash).isActive = true
            view.layer.cornerRadius = self.iconCash.frame.height/2
            self.iconCash.isHidden = true
            self.acreditationTimeLabel.isHidden = true
            self.accreditationTimeIcon.isHidden = true
            attributedTitle = NSMutableAttributedString(string : paymentMethod.name, attributes: [NSFontAttributeName: Utils.getFont(size: 20), NSForegroundColorAttributeName: ThemeManager.shared.getTheme().boldLabelTintColor()])
            
        } else {
            self.iconCash.image = MercadoPago.getOfflineReviewAndConfirmImage(paymentMethod)
            
            self.setTitle(paymentMethodOption, attributedTitle)

            self.acreditationTimeLabel.attributedText = NSMutableAttributedString(string: paymentMethodOption.getComment(), attributes: [NSFontAttributeName: Utils.getFont(size: 12)])
        }

        self.paymentMethodDescription.attributedText = attributedTitle

		if reviewScreenPreference.isChangeMethodOptionEnabled() {
			self.changePaymentButton.titleLabel?.font = Utils.getFont(size: 18)
			self.changePaymentButton.setTitle("Cambiar medio de pago".localized_temp, for: .normal)
		} else {
			self.changePaymentButton.isHidden = true
		}

        self.changePaymentButton.backgroundColor = .clear

        self.addSeparatorLineToBottom(height: 1)

        self.setNeedsUpdateConstraints()
        self.setNeedsLayout()
    }

    public static func getCellHeight(paymentMethodOption: PaymentMethodOption, reviewScreenPreference: ReviewScreenPreference = ReviewScreenPreference(), paymentMethod: PaymentMethod) -> CGFloat {

        var cellHeight = OfflinePaymentMethodCell.ROW_HEIGHT
        var buttonHeight: CGFloat = 48

        if paymentMethodOption.getId() == PaymentTypeId.ACCOUNT_MONEY.rawValue && paymentMethod.paymentTypeId != PaymentTypeId.PAYMENT_METHOD_PLUGIN.rawValue {
            cellHeight = 290
            buttonHeight = 80
        }

        if !reviewScreenPreference.isChangeMethodOptionEnabled() {
            cellHeight -= buttonHeight
        }

        return cellHeight
    }

  }
