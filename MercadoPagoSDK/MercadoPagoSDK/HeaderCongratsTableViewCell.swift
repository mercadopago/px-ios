//
//  HeaderCongratsTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/25/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class HeaderCongratsTableViewCell: UITableViewCell {

    @IBOutlet weak var messageError: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!

    @IBOutlet weak var subtitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code

        title.font = Utils.getFont(size: title.font.pointSize)
        messageError.text = ""
        messageError.font = Utils.getFont(size: messageError.font.pointSize)
        subtitle.text = ""
    }

    func fillCell(paymentResult: PaymentResult, paymentMethod: PaymentMethod?, color: UIColor, paymentResultScreenPreference: PaymentResultScreenPreference, checkoutPreference: CheckoutPreference) {

        view.backgroundColor = color

		if paymentResult.status ==  PaymentStatus.APPROVED {
            fillCellForAprrovedStatus(paymentResultScreenPreference: paymentResultScreenPreference)

        } else if paymentResult.status == PaymentStatus.IN_PROCESS {
            fillCellForPendingStatus(paymentResultScreenPreference: paymentResultScreenPreference)

        } else if paymentResult.statusDetail == RejectedStatusDetail.CALL_FOR_AUTH {
            fillCellForCallForAuthStatus(paymentResultScreenPreference: paymentResultScreenPreference, paymentResult: paymentResult, paymentMethod: paymentMethod, checkoutPreference: checkoutPreference)
        } else {
            fillCellForRejectedStatus(paymentResultScreenPreference: paymentResultScreenPreference, paymentResult: paymentResult, paymentMethod: paymentMethod)
        }
    }

    func fillCellForAprrovedStatus(paymentResultScreenPreference: PaymentResultScreenPreference) {
        icon.image = paymentResultScreenPreference.getHeaderApprovedIcon()
        title.text = paymentResultScreenPreference.getApprovedTitle()
        subtitle.text = paymentResultScreenPreference.getApprovedSubtitle()
    }

    func fillCellForPendingStatus(paymentResultScreenPreference: PaymentResultScreenPreference) {
        icon.image = paymentResultScreenPreference.getHeaderPendingIcon()
        title.text = paymentResultScreenPreference.getPendingTitle()
        subtitle.text = paymentResultScreenPreference.getPendingSubtitle()
    }

    func fillCellForCallForAuthStatus(paymentResultScreenPreference: PaymentResultScreenPreference, paymentResult: PaymentResult, paymentMethod: PaymentMethod?, checkoutPreference: CheckoutPreference) {
        icon.image = MercadoPago.getImage("MPSDK_payment_result_c4a")
        var titleWithParams: String = ""
        if let paymentMethodName = paymentMethod?.name {
            titleWithParams = ("Debes autorizar ante %p el pago de %t a MercadoPago".localized as NSString).replacingOccurrences(of: "%p", with: "\(paymentMethodName)")
        }
        let currency = MercadoPagoContext.getCurrency()
        let currencySymbol = currency.getCurrencySymbolOrDefault()
        let thousandSeparator = currency.getThousandsSeparatorOrDefault()
        let decimalSeparator = currency.getDecimalSeparatorOrDefault()

        let totalAmount = getTotalAmount(paymentData: paymentResult.paymentData, checkoutPreference: checkoutPreference)

        let amountRange = titleWithParams.range(of: "%t")

        if amountRange != nil {
            let attributedTitle = NSMutableAttributedString(string: (titleWithParams.substring(to: (amountRange?.lowerBound)!)), attributes: [NSFontAttributeName: Utils.getFont(size: 22)])
            let attributedAmount = Utils.getAttributedAmount(totalAmount, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator, currencySymbol: currencySymbol, color: UIColor.px_white())
            attributedTitle.append(attributedAmount)
            let endingTitle = NSAttributedString(string: (titleWithParams.substring(from: (amountRange?.upperBound)!)), attributes: [NSFontAttributeName: Utils.getFont(size: 22)])
            attributedTitle.append(endingTitle)
            self.title.attributedText = attributedTitle
        }
    }

    func getTotalAmount(paymentData: PaymentData?, checkoutPreference: CheckoutPreference) -> Double {
        guard let pd = paymentData, let payerCost = pd.payerCost else {
            return checkoutPreference.getAmount()
        }
        return payerCost.totalAmount
    }

    func fillCellForRejectedStatus(paymentResultScreenPreference: PaymentResultScreenPreference, paymentResult: PaymentResult, paymentMethod: PaymentMethod?) {
        icon.image = paymentResultScreenPreference.getHeaderRejectedIcon()
        let title = (paymentResult.statusDetail + "_title")
        if !title.existsLocalized() {
            if !String.isNullOrEmpty(paymentResultScreenPreference.getRejectedTitle()) {
                self.title.text = paymentResultScreenPreference.getRejectedTitle()
                subtitle.text = paymentResultScreenPreference.getRejectedSubtitle()
            } else {
                self.title.text = "Uy, no pudimos procesar el pago".localized
            }

        } else {
            if let paymentMethodName = paymentMethod?.name {
                let titleWithParams = (title.localized as NSString).replacingOccurrences(of: "%0", with: "\(paymentMethodName)")
                self.title.text = titleWithParams
            }
        }
        messageError.text = paymentResultScreenPreference.getRejectedIconSubtext()
    }

    func fillCell(instructionsInfo: InstructionsInfo, color: UIColor) {

        view.backgroundColor = color

        icon.image = MercadoPago.getImage("MPSDK_payment_result_off")
        let currency = MercadoPagoContext.getCurrency()
        let currencySymbol = currency.getCurrencySymbolOrDefault()
        let thousandSeparator = currency.getThousandsSeparatorOrDefault()
        let decimalSeparator = currency.getDecimalSeparatorOrDefault()

        let arr = String(instructionsInfo.amountInfo.amount).characters.split(separator: ".").map(String.init)
        let amountStr = Utils.getAmountFormatted(arr[0], thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator)
        let centsStr = Utils.getCentsFormatted(String(instructionsInfo.amountInfo.amount), decimalSeparator: decimalSeparator)
        let amountRange = instructionsInfo.instructions[0].title.range(of: currencySymbol + " " + amountStr + decimalSeparator + centsStr)

        if amountRange != nil {
            let attributedTitle = NSMutableAttributedString(string: (instructionsInfo.instructions[0].title.substring(to: (amountRange?.lowerBound)!)), attributes: [NSFontAttributeName: Utils.getFont(size: 22)])
            let attributedAmount = Utils.getAttributedAmount(instructionsInfo.amountInfo.amount, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator, currencySymbol: currencySymbol, color: UIColor.px_white())
            attributedTitle.append(attributedAmount)
            let endingTitle = NSAttributedString(string: (instructionsInfo.instructions[0].title.substring(from: (amountRange?.upperBound)!)), attributes: [NSFontAttributeName: Utils.getFont(size: 22)])
            attributedTitle.append(endingTitle)

            self.title.attributedText = attributedTitle
        } else {
            let attributedTitle = NSMutableAttributedString(string: (instructionsInfo.instructions[0].title), attributes: [NSFontAttributeName: Utils.getFont(size: 22)])
            self.title.attributedText = attributedTitle
        }
    }
}
