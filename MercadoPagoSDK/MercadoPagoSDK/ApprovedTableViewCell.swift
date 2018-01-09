//
//  ApprovedTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/26/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class ApprovedTableViewCell: UITableViewCell {

    @IBOutlet weak var paymentId: UILabel!
    @IBOutlet weak var installments: UILabel!
    @IBOutlet weak var installmentRate: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var paymentMethod: UIImageView!
    @IBOutlet weak var lastFourDigits: UILabel!
    @IBOutlet weak var statement: UILabel!
    @IBOutlet weak var comprobante: UILabel!
    @IBOutlet weak var idInstallmentConstraint: NSLayoutConstraint!

    @IBOutlet weak var discountViewHeight: NSLayoutConstraint!
    @IBOutlet weak var discountViewContent: UIView!
    @IBOutlet weak var paymentMethodStatementDescriptionConstraint: NSLayoutConstraint!
    @IBOutlet weak var paymentMethodTotalConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .none
        emptyTextLabel()
        setFonts()
    }

    func fillCell(paymentResult: PaymentResult, checkoutPreference: CheckoutPreference?, paymentResultScreenPreference: PaymentResultScreenPreference) {

        let currency = MercadoPagoContext.getCurrency()

        if !paymentResultScreenPreference.isPaymentIdDisable() {
            fillID(id: paymentResult._id)
        } else {
            idInstallmentConstraint.constant = 0
        }

        if !paymentResultScreenPreference.isAmountDisable() {
            if let payerCost = paymentResult.paymentData?.getPayerCost() {
                fillInstallmentLabel(amount: payerCost.totalAmount, payerCost: payerCost, currency: currency)
                fillInterestLabel(payerCost: payerCost)
                fillTotalLabel(payerCost: payerCost, currency: currency)

            } else  if MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable(), let discount = paymentResult.paymentData?.discount {
                fillInstallmentLabel(amount: discount.newAmount(), currency: currency)
                paymentMethodTotalConstraint.constant = 0
            } else if let amount = checkoutPreference?.getAmount() {
                fillInstallmentLabel(amount: amount, currency: currency)
                paymentMethodTotalConstraint.constant = 0
            }
        } else {
            paymentMethodTotalConstraint.constant = 0
        }

        if !paymentResultScreenPreference.isPaymentMethodDisable() {

            fillPaymentMethodIcon(paymentMethod: paymentResult.paymentData?.getPaymentMethod())

            fillPaymentMethodDescriptionLabel(paymentMethod: paymentResult.paymentData?.getPaymentMethod(), token: paymentResult.paymentData?.getToken())
        } else {
            paymentMethodTotalConstraint.constant = 0
        }

        fillStatementDescriptionLabel(description: paymentResult.statementDescription)

        if MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable(), let discount = paymentResult.paymentData?.discount {
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let discountBody = DiscountBodyCell(frame: CGRect(x: 0, y: 0, width : screenWidth, height : DiscountBodyCell.HEIGHT), coupon:discount, amount:(checkoutPreference?.getAmount())!, addBorder: false, hideArrow: true)
            discountViewContent.addSubview(discountBody)

        } else {
            discountViewHeight.constant = 0
        }
    }

    func fillID(id: String?) {
        if !String.isNullOrEmpty(id) {
            comprobante.text = "Comprobante".localized
            paymentId.text = "Nº \(id!)"

        } else {
            idInstallmentConstraint.constant = 0
        }
    }

    func fillInstallmentLabel(amount: Double, payerCost: PayerCost? = nil, currency: Currency) {

        if payerCost != nil {
            let attributedInstallment = Utils.getTransactionInstallmentsDescription(String(describing : payerCost!.installments), currency: currency, installmentAmount: payerCost!.installmentAmount, color:UIColor.black, fontSize: 24, centsFontSize: 11, baselineOffset:11)
            self.installments.attributedText  = attributedInstallment
        } else if amount != 0 {
            let totalAmount = Utils.getAttributedAmount(amount, thousandSeparator: String(currency.thousandsSeparator), decimalSeparator: String(currency.decimalSeparator), currencySymbol: String(currency.symbol), color:UIColor.black, fontSize: 24, centsFontSize: 11, baselineOffset:11)
            let installmentLabel = NSMutableAttributedString(string: "", attributes: [NSFontAttributeName: Utils.getFont(size: 24)])
            installmentLabel.append(totalAmount)
            self.installments.attributedText =  installmentLabel

        }

    }

    func fillInterestLabel(payerCost: PayerCost) {
        if !payerCost.hasInstallmentsRate() {

            if MercadoPagoCheckout.showBankInterestWarning() {
                installmentRate.text = "No incluye intereses bancarios".localized
                installmentRate.font = installmentRate.font.withSize(paymentId.font.pointSize)
                installmentRate.textColor = total.textColor
            } else {
                if MercadoPagoCheckout.showPayerCostDescription() {
                    installmentRate.text = "Sin interés".localized
                } else {
                    installmentRate.text = ""
                }
            }
        }
    }

    func fillTotalLabel(payerCost: PayerCost, currency: Currency) {
        if payerCost.totalAmount > 0 && payerCost.hasInstallmentsRate() {
            let attributedTotal = NSMutableAttributedString(attributedString: NSAttributedString(string: "( ", attributes: [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: Utils.getFont(size: 16)]))
            attributedTotal.append(Utils.getAttributedAmount(payerCost.totalAmount, thousandSeparator: String(currency.thousandsSeparator), decimalSeparator: String(currency.decimalSeparator), currencySymbol: String(currency.symbol), color: UIColor.black, fontSize:16, baselineOffset:4))
            attributedTotal.append(NSAttributedString(string: " )", attributes: [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: Utils.getFont(size: 16)]))
            total.attributedText = attributedTotal
        } else {
            paymentMethodTotalConstraint.constant = 0
        }
    }

    func fillPaymentMethodIcon(paymentMethod: PaymentMethod?) {

        var paymentMethodImage: UIImage? = MercadoPago.getImage(paymentMethod?._id)

        // Retrieve image for payment plugin or any external payment method.
        if paymentMethodImage == nil {
            paymentMethodImage = paymentMethod?.getImageForExtenalPaymentMethod()
        }

        self.paymentMethod.image = paymentMethodImage
    }

    func fillPaymentMethodDescriptionLabel(paymentMethod: PaymentMethod?, token: Token?) {
        if let token = token {
            self.lastFourDigits.text = "Terminada en ".localized + String(describing: token.lastFourDigits!)
        } else if let paymentMethod = paymentMethod {
            if paymentMethod.paymentTypeId == PaymentTypeId.ACCOUNT_MONEY.rawValue {
                self.lastFourDigits.text = "Con dinero en cuenta".localized
            } else if paymentMethod.paymentTypeId == PaymentTypeId.PAYMENT_METHOD_PLUGIN.rawValue {
                self.lastFourDigits.text = paymentMethod.name
            } else {
                self.lastFourDigits.text = ""
            }
        }
    }

    func fillStatementDescriptionLabel(description: String?) {
        if !String.isNullOrEmpty(description) {
            statement.text = ("En tu estado de cuenta verás el cargo como %0".localized as NSString).replacingOccurrences(of: "%0", with: "\(description!)")
        } else {
            paymentMethodStatementDescriptionConstraint.constant = 0
        }
    }

    func emptyTextLabel() {
        total.text = ""
        installmentRate.text = ""
        paymentId.text = ""
        comprobante.text = ""
        statement.text = ""
        installments.text = ""
        lastFourDigits.text = ""
    }

    func setFonts() {
        installmentRate.font = Utils.getFont(size: installmentRate.font.pointSize)
        comprobante.font = Utils.getFont(size: comprobante.font.pointSize)
        paymentId.font = Utils.getFont(size: paymentId.font.pointSize)
        statement.font = Utils.getFont(size: statement.font.pointSize)
        lastFourDigits.font = Utils.getFont(size: lastFourDigits.font.pointSize)
    }
}
