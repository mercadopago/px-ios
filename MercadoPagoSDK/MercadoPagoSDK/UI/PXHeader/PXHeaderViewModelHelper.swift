//
//  PXHeaderViewModelHelper.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 11/15/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

// MARK: Build Helpers
internal extension PXResultViewModel {
    func iconImageHeader() -> UIImage? {
        if paymentResult.isAccepted() {
            if self.paymentResult.isApproved() {
                return preference.getHeaderApprovedIcon() // * **
            } else if self.paymentResult.isWaitingForPayment() {
                return preference.getHeaderPendingIcon()
            } else {
                return preference.getHeaderImageFor(paymentResult.paymentData?.paymentMethod)
            }
        } else {
            return preference.getHeaderRejectedIcon(paymentResult.paymentData?.paymentMethod)
        }

    }

    func badgeImage() -> UIImage? {
        if !preference.showBadgeImage {
            return nil
        }
        return ResourceManager.shared.getBadgeImageWith(status: paymentResult.status, statusDetail: paymentResult.statusDetail)
    }

    func titleHeader(forNewResult: Bool = false) -> NSAttributedString {
        let fontSize = forNewResult ? PXNewResultHeader.TITLE_FONT_SIZE : PXHeaderRenderer.TITLE_FONT_SIZE

        if self.instructionsInfo != nil {
            return titleForInstructions()
        }
        if paymentResult.isAccepted() {
            if self.paymentResult.isApproved() {
                return getHeaderAttributedString(string: preference.getApprovedTitle(), size: fontSize)
            } else {
                return getHeaderAttributedString(string: "Estamos procesando el pago".localized, size: fontSize)
            }
        }
        if preference.rejectedTitleSetted {
            return getHeaderAttributedString(string: preference.getRejectedTitle(), size: fontSize)
        }
        return titleForStatusDetail(statusDetail: self.paymentResult.statusDetail, paymentMethod: self.paymentResult.paymentData?.paymentMethod)
    }

    func titleForStatusDetail(statusDetail: String, paymentMethod: PXPaymentMethod?) -> NSAttributedString {
        // Set title for remedy
        if let title = remedy?.cvv?.title {
            return title.toAttributedString()
        } else if let title = remedy?.highRisk?.title {
            return title.toAttributedString()
        } else if let title = remedy?.suggestedPaymentMethod?.title {
            return title.toAttributedString()
        }

        guard let paymentMethod = paymentMethod else {
            return "".toAttributedString()
        }
        // Set title for paymentMethod
        var statusDetail = statusDetail
        let badFilledKey = "cc_rejected_bad_filled"
        if statusDetail.contains(badFilledKey) {
            statusDetail = badFilledKey
        }

        let title = PXResourceProvider.getErrorTitleKey(statusDetail: statusDetail).localized
        return getTitleForRejected(paymentMethod, title)
    }

    func titleForInstructions() -> NSAttributedString {
        guard let instructionsInfo = self.instructionsInfo, let amountInfo = instructionsInfo.amountInfo else {
            return "".toAttributedString()
        }
        let currency = SiteManager.shared.getCurrency()
        let currencySymbol = currency.getCurrencySymbolOrDefault()
        let thousandSeparator = currency.getThousandsSeparatorOrDefault()
        let decimalSeparator = currency.getDecimalSeparatorOrDefault()

        let arr = String(amountInfo.amount).split(separator: ".").map(String.init)
        let amountStr = Utils.getAmountFormatted(arr[0], thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator)
        let centsStr = Utils.getCentsFormatted(String(amountInfo.amount), decimalSeparator: decimalSeparator)
        let amountRange = instructionsInfo.getInstruction()!.title.range(of: currencySymbol + " " + amountStr + decimalSeparator + centsStr)

        if let range = amountRange {
            let lowerBoundTitle = String(instructionsInfo.instructions[0].title[..<range.lowerBound])
            guard let attributedTitle = getHeaderAttributedString(string: lowerBoundTitle).mutableCopy() as? NSMutableAttributedString else { fatalError("Guaranteed cast to mutable sttributed string failed") }
            let attributedAmount = Utils.getAttributedAmount(amountInfo.amount, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator, currencySymbol: currencySymbol, color: .white, fontSize: PXHeaderRenderer.TITLE_FONT_SIZE, centsFontSize: PXHeaderRenderer.TITLE_FONT_SIZE / 2, smallSymbol: true)
            attributedTitle.append(attributedAmount)
            let upperBoundTitle = String(instructionsInfo.instructions[0].title[range.upperBound...])
            let endingTitle = getHeaderAttributedString(string: upperBoundTitle)
            attributedTitle.append(endingTitle)

            return attributedTitle
        } else {
            return getHeaderAttributedString(string: instructionsInfo.instructions[0].title, size: 26)
        }
    }

    func getTitleForRejected(_ paymentMethod: PXPaymentMethod, _ title: String) -> NSAttributedString {
        guard let paymentMethodName = paymentMethod.name else {
            return getDefaultRejectedTitle()
        }

        return getHeaderAttributedString(string: (title.localized as NSString).replacingOccurrences(of: "{0}", with: "\(paymentMethodName)"))
    }

    func getDefaultRejectedTitle() -> NSAttributedString {
        return getHeaderAttributedString(string: PXHeaderResutlConstants.REJECTED_HEADER_TITLE.localized)
    }

    func getHeaderAttributedString(string: String, size: CGFloat = PXHeaderRenderer.TITLE_FONT_SIZE) -> NSAttributedString {
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.font: Utils.getFont(size: size)])
    }
}
