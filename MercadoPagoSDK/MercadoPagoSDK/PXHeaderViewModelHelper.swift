//
//  PXHeaderViewModelHelper.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 11/15/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

extension PXResultViewModel {

    func getHeaderComponentProps() -> PXHeaderProps {
        let props = PXHeaderProps(labelText: labelTextHeader(), title: titleHeader(), backgroundColor: primaryResultColor(), productImage: iconImageHeader(), statusImage: badgeImage())
        return props
    }

    func buildHeaderComponent() -> PXHeaderComponent {
        let headerProps = getHeaderComponentProps()
        return PXHeaderComponent(props: headerProps)
    }
}

// MARK: Build Helpers
extension PXResultViewModel {
    func iconImageHeader() -> UIImage? {
        if isAccepted() {
            if self.paymentResult.isApproved() {
                return preference.getHeaderApprovedIcon() // * **
            } else if self.paymentResult.isWaitingForPayment() {
                return preference.getHeaderPendingIcon()
            } else {
                return preference.getHeaderImageFor(self.paymentResult.paymentData?.paymentMethod)
            }
        } else {
            return preference.getHeaderRejectedIcon(paymentResult.paymentData?.paymentMethod)
        }

    }

    func badgeImage() -> UIImage? {
        if !preference._showBadgeImage {
            return nil
        }
        if isAccepted() {
            if self.paymentResult.isApproved() {
                return preference.getApprovedBadgeImage()
            } else if self.paymentResult.isReviewManual() {
                return MercadoPago.getImage("orange_pending_badge")
            } else {
                return MercadoPago.getImage("pending_badge")
            }
        }
        if isWarning() {
            return MercadoPago.getImage("need_action_badge")
        }
        if  isError() {
            return MercadoPago.getImage("error_badge")
        }
        return nil
    }

    func labelTextHeader() -> NSAttributedString? {
        if isAccepted() {
            if self.paymentResult.isWaitingForPayment() {
                return "¡Apúrate a pagar!".localized.toAttributedString(attributes:[NSFontAttributeName: Utils.getFont(size: PXHeaderRenderer.LABEL_FONT_SIZE)])
            } else {
                var labelText: String?
                if self.paymentResult.isApproved() {
                    labelText = preference.getApprovedLabelText()
                } else {
                    labelText = preference.getPendingLabelText()
                }
                guard let text = labelText else {
                    return nil
                }
                return text.toAttributedString(attributes:[NSFontAttributeName: Utils.getFont(size: PXHeaderRenderer.LABEL_FONT_SIZE)])
            }
        }
        if !preference._showLabelText {
            return nil
        } else {
            return NSMutableAttributedString(string: "Algo salió mal...".localized, attributes: [NSFontAttributeName: Utils.getFont(size: PXHeaderRenderer.LABEL_FONT_SIZE)])
        }

    }
    func titleHeader() -> NSAttributedString {
        if let _ = self.instructionsInfo {
            return titleForInstructions()
        }
        if isAccepted() {
            if self.paymentResult.isApproved() {
                return NSMutableAttributedString(string: preference.getApprovedTitle(), attributes: [NSFontAttributeName: Utils.getFont(size: PXHeaderRenderer.TITLE_FONT_SIZE)])
            } else {
                return NSMutableAttributedString(string: "Estamos procesando el pago".localized, attributes: [NSFontAttributeName: Utils.getFont(size: PXHeaderRenderer.TITLE_FONT_SIZE)])
            }
        }
        if preference.rejectedTitleSetted {
            return NSMutableAttributedString(string: preference.getRejectedTitle(), attributes: [NSFontAttributeName: Utils.getFont(size: PXHeaderRenderer.TITLE_FONT_SIZE)])
        }
        return titleForStatusDetail(statusDetail: self.paymentResult.statusDetail, paymentMethod: self.paymentResult.paymentData?.paymentMethod)
    }

    func titleForStatusDetail(statusDetail: String, paymentMethod: PaymentMethod?) -> NSAttributedString {
        guard let paymentMethod = paymentMethod else {
            return "".toAttributedString()
        }

        if statusDetail == RejectedStatusDetail.CALL_FOR_AUTH {
            return getTitleForCallForAuth(paymentMethod)
        }

        let title = statusDetail + "_title"

        if title.existsLocalized() {
            return getTitleForRejected(paymentMethod, title)
        } else {
            return getDefaultRejectedTitle()
        }
    }

    func titleForInstructions() -> NSMutableAttributedString {
        guard let instructionsInfo = self.instructionsInfo else {
            return "".toAttributedString()
        }
        let currency = MercadoPagoContext.getCurrency()
        let currencySymbol = currency.getCurrencySymbolOrDefault()
        let thousandSeparator = currency.getThousandsSeparatorOrDefault()
        let decimalSeparator = currency.getDecimalSeparatorOrDefault()

        let arr = String(instructionsInfo.amountInfo.amount).characters.split(separator: ".").map(String.init)
        let amountStr = Utils.getAmountFormatted(arr[0], thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator)
        let centsStr = Utils.getCentsFormatted(String(instructionsInfo.amountInfo.amount), decimalSeparator: decimalSeparator)
        let amountRange = instructionsInfo.getInstruction()!.title.range(of: currencySymbol + " " + amountStr + decimalSeparator + centsStr)

        if let range = amountRange {
            let attributedTitle = NSMutableAttributedString(string: (instructionsInfo.instructions[0].title.substring(to: (range.lowerBound))), attributes: [NSFontAttributeName: Utils.getFont(size: PXHeaderRenderer.TITLE_FONT_SIZE)])
            let attributedAmount = Utils.getAttributedAmount(instructionsInfo.amountInfo.amount, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator, currencySymbol: currencySymbol, color: UIColor.px_white(), fontSize:PXHeaderRenderer.TITLE_FONT_SIZE, centsFontSize:PXHeaderRenderer.TITLE_FONT_SIZE/2, smallSymbol: true)
            attributedTitle.append(attributedAmount)
            let endingTitle = NSAttributedString(string: (instructionsInfo.instructions[0].title.substring(from: (range.upperBound))), attributes: [NSFontAttributeName: Utils.getFont(size: PXHeaderRenderer.TITLE_FONT_SIZE)])
            attributedTitle.append(endingTitle)

            return attributedTitle
        } else {
            let attributedTitle = NSMutableAttributedString(string: (instructionsInfo.instructions[0].title), attributes: [NSFontAttributeName: Utils.getFont(size: 26)])
            return attributedTitle
        }
    }

    func getTitleForCallForAuth(_ paymentMethod: PaymentMethod) -> NSAttributedString {
        if let paymentMethodName = paymentMethod.name {
            let currency = MercadoPagoContext.getCurrency()
            let currencySymbol = currency.getCurrencySymbolOrDefault()
            let thousandSeparator = currency.getThousandsSeparatorOrDefault()
            let decimalSeparator = currency.getDecimalSeparatorOrDefault()
            let amountStr = Utils.getAttributedAmount(amount, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator, currencySymbol: currencySymbol, color: UIColor.px_white(), fontSize:PXHeaderRenderer.TITLE_FONT_SIZE, centsFontSize:PXHeaderRenderer.TITLE_FONT_SIZE/2, smallSymbol: true)
            let string = "Debes autorizar ante %1$s el pago de ".localized.replacingOccurrences(of: "%1$s", with: "\(paymentMethodName)")
            let result: NSMutableAttributedString = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName: Utils.getFont(size: PXHeaderRenderer.TITLE_FONT_SIZE)])
            result.append(amountStr)
            result.append(NSMutableAttributedString(string: " a Mercado Pago".localized, attributes: [NSFontAttributeName: Utils.getFont(size: PXHeaderRenderer.TITLE_FONT_SIZE)]))
            return result
        } else {
            return "".toAttributedString()
        }
    }

    func getTitleForRejected(_ paymentMethod: PaymentMethod, _ title: String) -> NSAttributedString {
        if let paymentMethodName = paymentMethod.name {
            return NSMutableAttributedString(string: (title.localized as NSString).replacingOccurrences(of: "%0", with: "\(paymentMethodName)"), attributes: [NSFontAttributeName: Utils.getFont(size: PXHeaderRenderer.TITLE_FONT_SIZE)])
        } else {
            return "".toAttributedString()
        }
    }

    func getDefaultRejectedTitle() -> NSAttributedString {
        return NSMutableAttributedString(string: "Uy, no pudimos procesar el pago".localized, attributes: [NSFontAttributeName: Utils.getFont(size: PXHeaderRenderer.TITLE_FONT_SIZE)])
    }
}
