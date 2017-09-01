//
//  PaymentResultContentViewTest.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 4/29/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//
import XCTest
@testable import MercadoPagoSDK
class PaymentResultContentViewModelTest: BaseTest {
    var instance: PaymentResultContentViewModel!
    var paymentData: PaymentData!
    var paymentResult: PaymentResult!
    var paymentResultPreference = PaymentResultScreenPreference()

    override func setUp() {
        super.setUp()
        self.paymentData = MockBuilder.buildPaymentData(paymentMethodId: "visa", installments: 1, installmentRate: 0)
        self.paymentResult = PaymentResult(status: "rejected", statusDetail: "cc_rejected_bad_filled_securityCode", paymentData: paymentData, payerEmail: "sarsa@sarasita.com", id: "123", statementDescription: "mercadopago")
        self.instance = PaymentResultContentViewModel(paymentResult: paymentResult, paymentResultScreenPreference: paymentResultPreference)
    }

    func testStatusDetail() {
        XCTAssertEqual(self.instance.paymentResult.statusDetail, "cc_rejected_bad_filled_other")
        XCTAssertTrue(self.instance.hasStatusDetail())

        self.instance.paymentResult.statusDetail = ""
        XCTAssertFalse(self.instance.hasStatusDetail())
    }

    func testStastus() {
        self.instance.paymentResult.status = "rejected"
        XCTAssertTrue(self.instance.isPaymentRejected())
        XCTAssertFalse(self.instance.isPaymentPending())

        self.instance.paymentResult.status = "in_process"
        XCTAssertTrue(self.instance.isPaymentPending())
        XCTAssertFalse(self.instance.isPaymentRejected())
    }

    func testHeight() {
        var titleHeight: CGFloat = 0
        var subtitleHeight: CGFloat = 0
        /// Status : Rejected

        // StatusDetail: other_reason
        // Titulo
        // Subtitulo
        self.instance.paymentResult.status = "rejected"
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.OTHER_REASON
        XCTAssertEqual(self.instance.getMargingHeight(), self.instance.topMargin * 2 + self.instance.titleSubtitleMargin)

        titleHeight = UILabel.getHeight(width: UIScreen.main.bounds.width, font: Utils.getFont(size: self.instance.titleFontSize), text: self.instance.getTitle())
        subtitleHeight = UILabel.getHeight(width: UIScreen.main.bounds.width, font: Utils.getFont(size: self.instance.subtitleFontSize), text: self.instance.getSubtitle())
        XCTAssertEqual(self.instance.getHeight(), self.instance.getMargingHeight() + titleHeight + subtitleHeight)

        // StatusDetail: bad_filled
        // Titulo
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.BAD_FILLED_OTHER
        XCTAssertEqual(self.instance.getMargingHeight(), self.instance.topMargin * 2)

        titleHeight = UILabel.getHeight(width: UIScreen.main.bounds.width, font: Utils.getFont(size: self.instance.titleFontSize), text: self.instance.getTitle())
        XCTAssertEqual(self.instance.getHeight(), self.instance.getMargingHeight() + titleHeight)

        // StatusDetail: call_for_auth
        // Titulo
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.BAD_FILLED_OTHER
        XCTAssertEqual(self.instance.getMargingHeight(), self.instance.topMargin * 2)

        // StatusDetail: ""
        // Subtitulo
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.rejectedContentText = "Sarasa"
        self.instance.paymentResultScreenPreference.hideRejectedContentTitle = true
        self.instance.paymentResultScreenPreference.hideRejectedContentText = false
        XCTAssertEqual(self.instance.getMargingHeight(), self.instance.topMargin * 2)

        subtitleHeight = UILabel.getHeight(width: UIScreen.main.bounds.width, font: Utils.getFont(size: self.instance.subtitleFontSize), text: self.instance.getSubtitle())
        XCTAssertEqual(self.instance.getHeight(), self.instance.getMargingHeight() + subtitleHeight)

        // StatusDetail: ""
        // Titulo
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.rejectedContentTitle = "Sarasa"
        self.instance.paymentResultScreenPreference.hideRejectedContentText = true
        self.instance.paymentResultScreenPreference.hideRejectedContentTitle = false
        XCTAssertEqual(self.instance.getMargingHeight(), self.instance.topMargin * 2)

        // StatusDetail: ""
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.hideRejectedContentTitle = true
        self.instance.paymentResultScreenPreference.hideRejectedContentText = true
        XCTAssertEqual(self.instance.getMargingHeight(), 0)
        XCTAssertEqual(self.instance.getHeight(), 0)

        // StatusDetail: other_reason con paymentPreference
        // Titulo
        // Subtitlo
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.OTHER_REASON
        self.instance.paymentResultScreenPreference.hideRejectedContentTitle = true
        self.instance.paymentResultScreenPreference.hideRejectedContentText = true
        XCTAssertEqual(self.instance.getMargingHeight(), self.instance.topMargin * 2 + self.instance.titleSubtitleMargin)

        /// Status : Pending

        self.instance.paymentResult.status = "in_process"

        // Con statusDetail = "CONTINGENCY"
        // Titulo
        // Subtitilo
        self.instance.paymentResult.statusDetail = PendingStatusDetail.CONTINGENCY
        XCTAssertEqual(self.instance.getMargingHeight(), self.instance.topMargin * 2 + self.instance.titleSubtitleMargin)

        titleHeight = UILabel.getHeight(width: UIScreen.main.bounds.width, font: Utils.getFont(size: self.instance.titleFontSize), text: self.instance.getTitle())
        subtitleHeight = UILabel.getHeight(width: UIScreen.main.bounds.width, font: Utils.getFont(size: self.instance.subtitleFontSize), text: self.instance.getSubtitle())
        XCTAssertEqual(self.instance.getHeight(), self.instance.getMargingHeight() + titleHeight + subtitleHeight)

        // Con statusDetail = "REVIEW_MANUAL"
        // Titulo
        // Subtitilo
        self.instance.paymentResult.statusDetail = PendingStatusDetail.REVIEW_MANUAL
        XCTAssertEqual(self.instance.getMargingHeight(), self.instance.topMargin * 2 + self.instance.titleSubtitleMargin)

        // StatusDetail: ""
        // Subtitulo
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.pendingContentText = "Sarasa"
        self.instance.paymentResultScreenPreference.hidePendingContentTitle = true
        self.instance.paymentResultScreenPreference.hidePendingContentText = false
        XCTAssertEqual(self.instance.getMargingHeight(), self.instance.topMargin * 2)

        subtitleHeight = UILabel.getHeight(width: UIScreen.main.bounds.width, font: Utils.getFont(size: self.instance.subtitleFontSize), text: self.instance.getSubtitle())
        XCTAssertEqual(self.instance.getHeight(), self.instance.getMargingHeight() + subtitleHeight)

        // StatusDetail: ""
        // Titulo
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.pendingContentTitle = "Sarasa"
        self.instance.paymentResultScreenPreference.hidePendingContentText = true
        self.instance.paymentResultScreenPreference.hidePendingContentTitle = false
        XCTAssertEqual(self.instance.getMargingHeight(), self.instance.topMargin * 2)

        titleHeight = UILabel.getHeight(width: UIScreen.main.bounds.width, font: Utils.getFont(size: self.instance.titleFontSize), text: self.instance.getTitle())
        XCTAssertEqual(self.instance.getHeight(), self.instance.getMargingHeight() + titleHeight)

        // StatusDetail: ""
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.hidePendingContentTitle = true
        self.instance.paymentResultScreenPreference.hidePendingContentText = true
        XCTAssertEqual(self.instance.getMargingHeight(), 0)
        XCTAssertEqual(self.instance.getHeight(), 0)

        // Con statusDetail = "CONTINGENCY" con paymentPreference
        // Titulo
        // Subtitilo
        self.instance.paymentResult.statusDetail = PendingStatusDetail.CONTINGENCY
        self.instance.paymentResultScreenPreference.hidePendingContentTitle = true
        self.instance.paymentResultScreenPreference.hidePendingContentText = true
        XCTAssertEqual(self.instance.getMargingHeight(), self.instance.topMargin * 2 + self.instance.titleSubtitleMargin)

    }

    //*********************
    // Rejected Payments
    //*********************

    func testRejectedGetTitle() {
        self.instance.paymentResult.status = "rejected"

        // Con statusDetail = "other_reason"
        // ¿Que puede hacer?
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.OTHER_REASON
        XCTAssertTrue(self.instance.hasTitle())
        XCTAssertEqual(self.instance.getTitle(), self.instance.defaultTitle)

        // Con statusDetail = "cc_rejected_call_for_authorize"
        // ¿No pudiste autorizarlo?
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.CALL_FOR_AUTH
        XCTAssertTrue(self.instance.hasTitle())
        XCTAssertEqual(self.instance.getTitle(), (paymentResult.statusDetail + "_title").localized)

        // Con statusDetail = "" y sin PaymentResultScreenPreference
        // ¿Que puedo hacer?
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.rejectedContentTitle = ""
        XCTAssertTrue(self.instance.hasTitle())
        XCTAssertEqual(self.instance.getTitle(), self.instance.defaultTitle)

        // Con statusDetail = "" y con PaymentResultScreenPreference
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.rejectedContentTitle = "Sarasa"

        XCTAssertTrue(self.instance.hasTitle())
        XCTAssertEqual(self.instance.getTitle(), "Sarasa")

        // Con statusDetail = "other_reason" y con PaymentResultScreenPreference
        // ¿Que puede hacer?
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.OTHER_REASON
        self.instance.paymentResultScreenPreference.rejectedContentTitle = "Sarasa"
        XCTAssertTrue(self.instance.hasTitle())
        XCTAssertEqual(self.instance.getTitle(), self.instance.defaultTitle)

        // Con statusDetail = "other_reason" y titulo deshabilitado
        // ¿Que puede hacer?
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.OTHER_REASON
        self.instance.paymentResultScreenPreference.hideRejectedContentTitle = true
        XCTAssertTrue(self.instance.hasTitle())
        XCTAssertEqual(self.instance.getTitle(), self.instance.defaultTitle)

        // Con statusDetail = "" y titulo deshabilitado
        // No se deberia mostrar titulo
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.hideRejectedContentTitle = true
        XCTAssertFalse(self.instance.hasTitle())

    }

    func testRejectedGetSubtitle() {
        self.instance.paymentResult.status = "rejected"
        self.instance.paymentResult.paymentData?.paymentMethod!.paymentTypeId = "credit_card"
        self.instance.paymentResult.paymentData?.paymentMethod!.name = "Visa"

        // Con statusDetail = "other_reason"
        // Hay subtitulo
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.OTHER_REASON
        XCTAssertTrue(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), (self.instance.paymentResult.statusDetail + "_subtitle_" + "credit_card").localized)

        // Con statusDetail = "high_risk"
        // Hay subtitulo
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.HIGH_RISK
        XCTAssertTrue(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), (self.instance.paymentResult.statusDetail + "_subtitle_" + "credit_card").localized)

        // Con statusDetail = "max_attemps"
        // Hay subtitulo
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.MAX_ATTEMPTS
        XCTAssertTrue(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), (self.instance.paymentResult.statusDetail + "_subtitle_" + "credit_card").localized)

        // Con statusDetail = "CARD_DISABLE"
        // Hay subtitulo
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.CARD_DISABLE
        XCTAssertTrue(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), (self.instance.paymentResult.statusDetail + "_subtitle_" + "credit_card").localized)

        // Con statusDetail = "BAD_FILLED_OTHER"
        // Hay subtitulo
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.BAD_FILLED_OTHER
        XCTAssertFalse(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), "")

        // Con statusDetail = "DUPLICATED_PAYMENT"
        // Hay subtitulo
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.DUPLICATED_PAYMENT
        XCTAssertTrue(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), (self.instance.paymentResult.statusDetail + "_subtitle_" + "credit_card").localized)

        // Con statusDetail = "INSUFFICIENT_AMOUNT"
        // Hay subtitulo
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.INSUFFICIENT_AMOUNT
        XCTAssertTrue(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), (self.instance.paymentResult.statusDetail + "_subtitle_" + "credit_card").localized)

        // Con statusDetail = "cc_rejected_call_for_authorize"
        // No hay subtitulo
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.CALL_FOR_AUTH
        XCTAssertFalse(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), "")

        // Con statusDetail = "" y sin PaymentResultScreenPreference
        // NO se deberia mostrar subtitulo
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.rejectedContentText = ""
        XCTAssertFalse(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), "")

        // Con statusDetail = "" y con PaymentResultScreenPreference
        // Sarasa
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.rejectedContentText = "Sarasa"

        XCTAssertTrue(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), "Sarasa")

        // Con statusDetail = "other_reason" y con PaymentResultScreenPreference
        // Se deberia mostrar nuestro subtitulo
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.OTHER_REASON
        self.instance.paymentResultScreenPreference.rejectedContentTitle = "Sarasa"
        XCTAssertTrue(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), (self.instance.paymentResult.statusDetail + "_subtitle_" + "credit_card").localized)

        // Con statusDetail = "other_reason" y subtitulo deshabilitado
        // Hay subtitulo
        self.instance.paymentResult.statusDetail = RejectedStatusDetail.OTHER_REASON
        self.instance.paymentResultScreenPreference.hideRejectedContentText = true
        XCTAssertTrue(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), (self.instance.paymentResult.statusDetail + "_subtitle_" + "credit_card").localized)

        // Con statusDetail = "" y titulo deshabilitado
        // No se deberia mostrar subtitulo
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.hideRejectedContentText = true
        XCTAssertFalse(self.instance.hasSubtitle())
    }

    //*********************
    // Pending Payments
    //*********************

    func testPendingGetTitle() {
        self.instance.paymentResult.status = "in_process"

        // Con statusDetail = "CONTINGENCY"
        // ¿Que puede hacer?
        self.instance.paymentResult.statusDetail = PendingStatusDetail.CONTINGENCY
        XCTAssertTrue(self.instance.hasTitle())
        XCTAssertEqual(self.instance.getTitle(), self.instance.defaultTitle)

        // Con statusDetail = "REVIEW_MANUAL"
        // ¿Que puede hacer?
        self.instance.paymentResult.statusDetail = PendingStatusDetail.REVIEW_MANUAL
        XCTAssertTrue(self.instance.hasTitle())
        XCTAssertEqual(self.instance.getTitle(), self.instance.defaultTitle)

        // Con statusDetail = "" y sin PaymentResultScreenPreference
        // ¿Que puedo hacer?
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.pendingContentTitle = ""
        XCTAssertTrue(self.instance.hasTitle())
        XCTAssertEqual(self.instance.getTitle(), self.instance.defaultTitle)

        // Con statusDetail = "" y con PaymentResultScreenPreference
        // Sarasa
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.pendingContentTitle = "Sarasa"

        XCTAssertTrue(self.instance.hasTitle())
        XCTAssertEqual(self.instance.getTitle(), "Sarasa")

        // Con statusDetail = "CONTINGENCY" y con PaymentResultScreenPreference
        // ¿Que puede hacer?
        self.instance.paymentResult.statusDetail = PendingStatusDetail.CONTINGENCY
        self.instance.paymentResultScreenPreference.pendingContentTitle = "Sarasa"
        XCTAssertTrue(self.instance.hasTitle())
        XCTAssertEqual(self.instance.getTitle(), self.instance.defaultTitle)

        // Con statusDetail = "other_reason" y titulo deshabilitado
        // ¿Que puede hacer?
        self.instance.paymentResult.statusDetail = PendingStatusDetail.CONTINGENCY
        self.instance.paymentResultScreenPreference.hidePendingContentTitle = true
        XCTAssertTrue(self.instance.hasTitle())
        XCTAssertEqual(self.instance.getTitle(), self.instance.defaultTitle)

        // Con statusDetail = "" y titulo deshabilitado
        // No se deberia mostrar titulo
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.hidePendingContentTitle = true
        XCTAssertFalse(self.instance.hasTitle())

    }

    func testPendingGetSubtitle() {
        self.instance.paymentResult.status = "in_process"
        self.instance.paymentResult.paymentData?.paymentMethod!.paymentTypeId = "credit_card"
        self.instance.paymentResult.paymentData?.paymentMethod!.name = "Visa"

        // Con statusDetail = "CONTINGENCY"
        // Hay subtitulo
        self.instance.paymentResult.statusDetail = PendingStatusDetail.CONTINGENCY
        XCTAssertTrue(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), "En menos de 1 hora te enviaremos por e-mail el resultado.".localized)

        // Con statusDetail = "REVIEW_MANUAL"
        // Hay subtitulo
        self.instance.paymentResult.statusDetail = PendingStatusDetail.REVIEW_MANUAL
        XCTAssertTrue(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), "En menos de 2 días hábiles te diremos por e-mail si se acreditó o si necesitamos más información.".localized)

        // Con statusDetail = "" y sin PaymentResultScreenPreference
        // NO se deberia mostrar subtitulo
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.rejectedContentText = ""
        XCTAssertFalse(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), "")

        // Con statusDetail = "" y con PaymentResultScreenPreference
        // Sarasa
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.pendingContentText = "Sarasa"

        XCTAssertTrue(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), "Sarasa")

        // Con statusDetail = "other_reason" y con PaymentResultScreenPreference
        // Se deberia mostrar nuestro subtitulo
        self.instance.paymentResult.statusDetail = PendingStatusDetail.CONTINGENCY
        self.instance.paymentResultScreenPreference.pendingContentText = "Sarasa"
        XCTAssertTrue(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), "En menos de 1 hora te enviaremos por e-mail el resultado.".localized)

        // Con statusDetail = "other_reason" y subtitulo deshabilitado
        // Hay subtitulo
        self.instance.paymentResult.statusDetail = PendingStatusDetail.CONTINGENCY
        self.instance.paymentResultScreenPreference.hidePendingContentText = true
        XCTAssertTrue(self.instance.hasSubtitle())
        XCTAssertEqual(self.instance.getSubtitle(), "En menos de 1 hora te enviaremos por e-mail el resultado.".localized)

        // Con statusDetail = "" y titulo deshabilitado
        // No se deberia mostrar subtitulo
        self.instance.paymentResult.statusDetail = ""
        self.instance.paymentResultScreenPreference.hidePendingContentText = true
        XCTAssertFalse(self.instance.hasSubtitle())
    }

}
