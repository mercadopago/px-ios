//
//  PaymentResultContentView.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 4/27/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

class PaymentResultContentView: UIView {
    var viewModel: PaymentResultContentViewModel!

    var height: CGFloat = 0
    var rect =  CGRect(x: 0, y: 0, width : UIScreen.main.bounds.width, height : 0)

    init(paymentResult: PaymentResult, paymentResultScreenPreference: PaymentResultScreenPreference) {
        super.init(frame: rect)

        self.viewModel = PaymentResultContentViewModel(paymentResult: paymentResult, paymentResultScreenPreference: paymentResultScreenPreference)

        height = self.viewModel.topMargin

        if self.viewModel.hasTitle() {
            makeLabel(text: self.viewModel.getTitle(), fontSize: self.viewModel.titleFontSize)
        }

        if self.viewModel.hasSubtitle() && self.viewModel.hasTitle() {
            height += self.viewModel.titleSubtitleMargin
        }

        if self.viewModel.hasSubtitle() {
            makeLabel(text: self.viewModel.getSubtitle(), fontSize: self.viewModel.subtitleFontSize)
        }

        self.frame = CGRect(x: 0, y: 0, width : UIScreen.main.bounds.width, height : self.viewModel.getHeight())
    }

    override init(frame: CGRect) {
        super.init(frame: rect)
    }

    func makeLabel(text: String, fontSize: CGFloat, color: UIColor = UIColor.px_grayDark()) {
        let label = MPLabel()
        label.text = text
        label.font = Utils.getFont(size: fontSize)
        label.textColor = color
        label.textAlignment = .center
        label.frame = CGRect(x: self.viewModel.leftMargin, y: height, width: frame.size.width - (2 * self.viewModel.leftMargin), height: 0)
        let frameLabel = CGRect(x: self.viewModel.leftMargin, y: height, width: frame.size.width - (2 * self.viewModel.leftMargin), height: label.requiredHeight())
        label.frame = frameLabel
        label.numberOfLines = 0
        height += label.requiredHeight()
        self.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PaymentResultContentViewModel: NSObject {
    let topMargin: CGFloat = 50
    let leftMargin: CGFloat = 15
    let titleSubtitleMargin: CGFloat = 20

    let titleFontSize: CGFloat = 22
    let subtitleFontSize: CGFloat = 18

    let paymentResult: PaymentResult
    var paymentResultScreenPreference: PaymentResultScreenPreference

    let defaultTitle = "¿Qué puedo hacer?".localized

    init(paymentResult: PaymentResult, paymentResultScreenPreference: PaymentResultScreenPreference) {
        self.paymentResult = paymentResult
        self.paymentResultScreenPreference = paymentResultScreenPreference

        if paymentResult.statusDetail.contains("cc_rejected_bad_filled") {
            paymentResult.statusDetail = "cc_rejected_bad_filled_other"
        }
    }

    func getHeight() -> CGFloat {
        var height = getMargingHeight()

        // Title Height
        if hasTitle () {
            height += UILabel.getHeight(width: UIScreen.main.bounds.width, font: Utils.getFont(size: self.titleFontSize), text: self.getTitle())
        }

        // Subtitle Height
        if hasSubtitle() {
            height += UILabel.getHeight(width: UIScreen.main.bounds.width, font: Utils.getFont(size: self.subtitleFontSize), text: self.getSubtitle())
        }

        return height
    }

    func getMargingHeight() -> CGFloat {
        if !hasTitle() && !hasSubtitle() {
            return 0
        }
        // Top and bottom Margin
        var heigth = 2 * self.topMargin

        // Title and Subtitle Margin
        if self.hasTitle() && self.hasSubtitle() {
            heigth += self.titleSubtitleMargin
        }
        return heigth
    }

    func hasTitle() -> Bool {
        // If there is a statusDetail, the preference is ignore
        let caseNoPrefernece = getTitle() != "" && hasStatusDetail()
        let caseRejectedPreference = !paymentResultScreenPreference.isRejectedContentTitleDisable() && paymentResult.statusDetail == ""  && getTitle() != "" && isPaymentRejected()
        let casePendingPreference = !paymentResultScreenPreference.isPendingContentTitleDisable() && paymentResult.statusDetail == ""  && getTitle() != "" && isPaymentPending()

        return caseNoPrefernece || caseRejectedPreference || casePendingPreference
    }

    func hasStatusDetail() -> Bool {
        return paymentResult.statusDetail != ""
    }

    func isPaymentRejected() -> Bool {
        return paymentResult.status == PaymentStatus.REJECTED
    }

    func isPaymentPending() -> Bool {
        return  paymentResult.status == PaymentStatus.IN_PROCESS
    }

    func hasSubtitle() -> Bool {
        // If there is a statusDetail, the preference is ignore
        let caseNoPreference = getSubtitle() != "" && hasStatusDetail()
        let caseRejectedPreferene = !paymentResultScreenPreference.isRejectedContentTextDisable() && !hasStatusDetail() && isPaymentRejected() && getSubtitle() != ""
        let casePendingPreference = !paymentResultScreenPreference.isPendingContentTextDisable() && !hasStatusDetail() && isPaymentPending() && getSubtitle() != ""

        return caseNoPreference || caseRejectedPreferene || casePendingPreference
    }

    func getTitle() -> String {
        if isPaymentRejected() {
            return getRejectedTitle()
        } else if isPaymentPending() {
            return getPendingTitle()
        }
        return defaultTitle
    }

    func getRejectedTitle() -> String {
        if paymentResult.statusDetail == RejectedStatusDetail.CALL_FOR_AUTH {
            return (paymentResult.statusDetail + "_title").localized
        } else if paymentResult.statusDetail != "" {
            return defaultTitle
        } else if !String.isNullOrEmpty(paymentResultScreenPreference.getRejectedContetTitle()) {
            return paymentResultScreenPreference.getRejectedContetTitle()
        }
        return defaultTitle
    }

    func getPendingTitle() -> String {
        if !String.isNullOrEmpty(paymentResultScreenPreference.getPendingContetTitle()) && paymentResult.statusDetail == ""{
            return paymentResultScreenPreference.getPendingContetTitle()
        }
        return defaultTitle
    }

    func getSubtitle() -> String {
        if isPaymentRejected() {
            return getRejectedSubtitle()
        } else if isPaymentPending() {
            return getPendingSubtitle()
        }
        return ""
    }

    func getRejectedSubtitle() -> String {
        if paymentResult.statusDetail != "" {
            
            if (paymentResult.paymentData?.paymentMethod?.isBolbradesco)! {
                return "Por favor, intenta pagar con otro medio.".localized
            }

            let paymentTypeID = paymentResult.paymentData?.getPaymentMethod()?.paymentTypeId ?? "credit_card"
            let subtitle = (paymentResult.statusDetail + "_subtitle_" + paymentTypeID)

            if subtitle.existsLocalized() {
                let paymentMethodName = paymentResult.paymentData?.getPaymentMethod()?.name.localized ?? ""
                return (subtitle.localized as NSString).replacingOccurrences(of: "%0", with: "\(paymentMethodName)")
            }
        } else if !String.isNullOrEmpty(paymentResultScreenPreference.getRejectedContentText()) {
            return paymentResultScreenPreference.getRejectedContentText()
        }
        return ""
    }

    func getPendingSubtitle() -> String {
        if paymentResult.statusDetail == PendingStatusDetail.CONTINGENCY {
            return "En menos de 1 hora te enviaremos por e-mail el resultado.".localized

        } else if paymentResult.statusDetail == PendingStatusDetail.REVIEW_MANUAL {
            return "En menos de 2 días hábiles te diremos por e-mail si se acreditó o si necesitamos más información.".localized

        } else if !String.isNullOrEmpty(paymentResultScreenPreference.getPendingContentText()) {
            return paymentResultScreenPreference.getPendingContentText()
        }
        return ""
    }
}
