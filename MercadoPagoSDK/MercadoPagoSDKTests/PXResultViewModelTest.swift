//
//  PXResultViewModelTest.swift
//  MercadoPagoSDKTests
//
//  Created by Demian Tejo on 31/10/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class PXResultViewModelTest: BaseTest {

    let approvedTitleDummy = "ATD"
    let rejectedTitleDummy = "RTD"
    let pendingTitleDummy = "PTD"
    let approvedLabelDummy = "ALD"

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        MercadoPagoContext.setLanguage(language: Languages._ENGLISH)
        super.tearDown()
    }

    func testViewModelWithoutPreferenceAndApprovedPayment() {
        let paymentResult = MockBuilder.buildPaymentResult("approved", paymentMethodId: "visa")
        paymentResult.paymentData?.token = MockBuilder.buildToken()
        paymentResult.paymentData?.issuer = MockBuilder.buildIssuer()
        paymentResult.paymentData?.issuer?.name = "RIO"
        paymentResult.paymentData?.payerCost = PayerCost(installments: 3, installmentRate: 1, labels: [], minAllowedAmount: 123, maxAllowedAmount: 123, recommendedMessage: "", installmentAmount: 100, totalAmount: 300)
        paymentResult.paymentData?.token?.lastFourDigits = "1234"
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil)
        let headerView = buildHeaderView(resultViewModel: resultViewModel)
        let footerView = buildFooterView(resultViewModel: resultViewModel)
        let bodyView = buildBodyView(resultViewModel: resultViewModel)
        let receiptView = buildReceiptView(resultViewModel: resultViewModel)
        let topCustomComponent = resultViewModel.getTopCustomComponent()
        let bottomCustomComponent = resultViewModel.getBottomCustomComponent()
        guard let paymentMethodView = bodyView as? PXPaymentMethodView else {
            XCTAssertTrue(false, "The view is not of the expected class")
            return
        }
        XCTAssertNil(topCustomComponent)
        XCTAssertNil(bottomCustomComponent)
        XCTAssertNotNil(receiptView.dateLabel)
        XCTAssertNotNil(receiptView.detailLabel)
        XCTAssertNotNil(paymentMethodView.paymentMethodIcon)
        XCTAssertEqual(paymentMethodView.amountTitle?.text, "3x $ 100")
        XCTAssertEqual(paymentMethodView.amountDetail?.text, "($ 300)")
        XCTAssertEqual(paymentMethodView.paymentMethodDescription?.text, "visa ending in 1234")
        XCTAssertEqual(paymentMethodView.paymentMethodDetail?.text, "RIO")
        XCTAssertEqual(paymentMethodView.disclaimerLabel?.text, "In your account yo will see the charge as description")
        XCTAssertEqual(headerView.backgroundColor, UIColor.pxGreenMp)
        XCTAssertNil(footerView.principalButton)
        XCTAssertEqual(footerView.linkButton?.title(for: .normal), "Seguir comprando".localized)
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("default_item_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("ok_badge"))
        XCTAssertNil(headerView.statusLabel?.attributedText)
        XCTAssertEqual(headerView.messageLabel?.attributedText?.string, "¡Listo! Se acreditó tu pago".localized)
        XCTAssertTrue(resultViewModel.isAccepted())
        XCTAssertFalse(resultViewModel.isWarning())
        XCTAssertFalse(resultViewModel.isError())
    }

    func testViewModelWithoutPreferenceAndApprovedPaymentAccountMoney() {
        let paymentResult = MockBuilder.buildPaymentResult("approved", paymentMethodId: "account_money")
        paymentResult.paymentData?.paymentMethod?.paymentTypeId = "account_money"
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil)
        let headerView = buildHeaderView(resultViewModel: resultViewModel)
        let footerView = buildFooterView(resultViewModel: resultViewModel)
        let bodyView = buildBodyView(resultViewModel: resultViewModel)
        let receiptView = buildReceiptView(resultViewModel: resultViewModel)
        let topCustomComponent = resultViewModel.getTopCustomComponent()
        let bottomCustomComponent = resultViewModel.getBottomCustomComponent()
        guard let paymentMethodView = bodyView as? PXPaymentMethodView else {
            XCTAssertTrue(false, "The view is not of the expected class")
            return
        }
        XCTAssertNil(topCustomComponent)
        XCTAssertNil(bottomCustomComponent)
        XCTAssertNotNil(receiptView.dateLabel)
        XCTAssertNotNil(receiptView.detailLabel)
        XCTAssertNotNil(paymentMethodView.paymentMethodIcon)
        XCTAssertEqual(paymentMethodView.amountTitle?.text, "$ 1.000")
        XCTAssertNil(paymentMethodView.amountDetail?.text)
        XCTAssertEqual(paymentMethodView.paymentMethodDescription?.text, "account_money")
        XCTAssertNil(paymentMethodView.paymentMethodDetail?.text)
        XCTAssertEqual(paymentMethodView.disclaimerLabel?.text, "In your account yo will see the charge as description")
        XCTAssertEqual(headerView.backgroundColor, UIColor.pxGreenMp)
        XCTAssertNil(footerView.principalButton)
        XCTAssertEqual(footerView.linkButton?.title(for: .normal), "Seguir comprando".localized)
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("default_item_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("ok_badge"))
        XCTAssertNil(headerView.statusLabel?.attributedText)
        XCTAssertEqual(headerView.messageLabel?.attributedText?.string, "¡Listo! Se acreditó tu pago".localized)
        XCTAssertTrue(resultViewModel.isAccepted())
        XCTAssertFalse(resultViewModel.isWarning())
        XCTAssertFalse(resultViewModel.isError())
    }

    func testViewModelWithoutPreferenceAndRejectedPayment() {
        let paymentResult = MockBuilder.buildPaymentResult("rejected", paymentMethodId: "visa")
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil)
        let headerView = buildHeaderView(resultViewModel: resultViewModel)
        let footerView = buildFooterView(resultViewModel: resultViewModel)
        let receiptView = buildReceiptView(resultViewModel: resultViewModel)
        let topCustomComponent = resultViewModel.getTopCustomComponent()
        let bottomCustomComponent = resultViewModel.getBottomCustomComponent()
        XCTAssertNil(topCustomComponent)
        XCTAssertNil(bottomCustomComponent)
        XCTAssertNil(receiptView.dateLabel)
        XCTAssertNil(receiptView.detailLabel)
        XCTAssertEqual(footerView.principalButton?.title(for: .normal), "Pagar con otro medio".localized)
        XCTAssertEqual(footerView.linkButton?.title(for: .normal), "Cancelar pago".localized)
        XCTAssertEqual(headerView.backgroundColor, UIColor.pxRedMp)
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("card_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("error_badge"))
        XCTAssertEqual(headerView.statusLabel?.attributedText?.string, "Algo salió mal...".localized)
        XCTAssertFalse(resultViewModel.isAccepted())
        XCTAssertFalse(resultViewModel.isWarning())
        XCTAssertTrue(resultViewModel.isError())
    }

    func testViewModelWithoutPreferenceAndPendingPayment() {
        let paymentResult = MockBuilder.buildPaymentResult("in_process", paymentMethodId: "visa")
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil)
        let headerView = buildHeaderView(resultViewModel: resultViewModel)
        let footerView = buildFooterView(resultViewModel: resultViewModel)
        let receiptView = buildReceiptView(resultViewModel: resultViewModel)
        let topCustomComponent = resultViewModel.getTopCustomComponent()
        let bottomCustomComponent = resultViewModel.getBottomCustomComponent()
        XCTAssertNil(topCustomComponent)
        XCTAssertNil(bottomCustomComponent)
        XCTAssertNil(receiptView.dateLabel)
        XCTAssertNil(receiptView.detailLabel)
        XCTAssertNil(footerView.principalButton)
        XCTAssertEqual(footerView.linkButton?.title(for: .normal), "Seguir comprando".localized)
        XCTAssertEqual(headerView.backgroundColor, UIColor.pxGreenMp)
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("card_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("pending_badge"))
        XCTAssertNil(headerView.statusLabel?.attributedText)
        XCTAssertEqual(headerView.messageLabel?.attributedText?.string, "Estamos procesando el pago".localized)
        XCTAssertTrue(resultViewModel.isAccepted())
        XCTAssertFalse(resultViewModel.isWarning())
        XCTAssertFalse(resultViewModel.isError())
    }

    func testViewModelWithTextPreferenceAndApprovedPayment() {
        let preference = PaymentResultScreenPreference()
        preference.setApproved(title: approvedTitleDummy)
        preference.setApproved(labelText: approvedLabelDummy)
        preference.disableApprovedReceipt()
        let paymentResult = MockBuilder.buildPaymentResult("approved", paymentMethodId: "visa")
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil, paymentResultScreenPreference:preference)
        paymentResult.paymentData?.token = MockBuilder.buildToken()
        paymentResult.paymentData?.token?.lastFourDigits = "1234"
        let headerView = buildHeaderView(resultViewModel: resultViewModel)
        let footerView = buildFooterView(resultViewModel: resultViewModel)
        let bodyView = buildBodyView(resultViewModel: resultViewModel)
        let receiptView = buildReceiptView(resultViewModel: resultViewModel)
        let topCustomComponent = resultViewModel.getTopCustomComponent()
        let bottomCustomComponent = resultViewModel.getBottomCustomComponent()
        guard let paymentMethodView = bodyView as? PXPaymentMethodView else {
            XCTAssertTrue(false, "The view is not of the expected class")
            return
        }
        XCTAssertNil(topCustomComponent)
        XCTAssertNil(bottomCustomComponent)
        XCTAssertNil(receiptView.dateLabel)
        XCTAssertNil(receiptView.detailLabel)
        XCTAssertNotNil(paymentMethodView.paymentMethodIcon)
        XCTAssertEqual(paymentMethodView.amountTitle?.text, "$ 1.000")
        XCTAssertNil(paymentMethodView.amountDetail?.text)
        XCTAssertEqual(paymentMethodView.paymentMethodDescription?.text, "visa ending in 1234")
        XCTAssertNil(paymentMethodView.paymentMethodDetail?.text)
        XCTAssertEqual(paymentMethodView.disclaimerLabel?.text, "In your account yo will see the charge as description")
        XCTAssertNil(footerView.principalButton)
        XCTAssertEqual(footerView.linkButton?.title(for: .normal), "Seguir comprando".localized)
        XCTAssertEqual(headerView.backgroundColor, UIColor.pxGreenMp)
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("default_item_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("ok_badge"))
        XCTAssertTrue(resultViewModel.isAccepted())
        XCTAssertFalse(resultViewModel.isWarning())
        XCTAssertFalse(resultViewModel.isError())
        XCTAssertEqual(headerView.statusLabel?.attributedText?.string, approvedLabelDummy)
        XCTAssertEqual(headerView.messageLabel?.attributedText?.string, approvedTitleDummy)
    }

    func testViewModelWithTextPreferenceAndRejectedPayment() {
        let preference = PaymentResultScreenPreference()
        preference.setRejected(title: rejectedTitleDummy)
        let paymentResult = MockBuilder.buildPaymentResult("rejected", paymentMethodId: "visa")
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil, paymentResultScreenPreference: preference)
        let headerView = buildHeaderView(resultViewModel: resultViewModel)
        let footerView = buildFooterView(resultViewModel: resultViewModel)
        let receiptView = buildReceiptView(resultViewModel: resultViewModel)
        let topCustomComponent = resultViewModel.getTopCustomComponent()
        let bottomCustomComponent = resultViewModel.getBottomCustomComponent()
        XCTAssertNil(topCustomComponent)
        XCTAssertNil(bottomCustomComponent)
        XCTAssertNil(receiptView.dateLabel)
        XCTAssertNil(receiptView.detailLabel)
        XCTAssertEqual(footerView.principalButton?.title(for: .normal), "Pagar con otro medio".localized)
        XCTAssertEqual(footerView.linkButton?.title(for: .normal), "Cancelar pago".localized)
        XCTAssertEqual(headerView.backgroundColor, UIColor.pxRedMp)
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("card_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("error_badge"))
        XCTAssertFalse(resultViewModel.isAccepted())
        XCTAssertFalse(resultViewModel.isWarning())
        XCTAssertTrue(resultViewModel.isError())
        XCTAssertEqual(headerView.messageLabel?.attributedText?.string, rejectedTitleDummy)
        XCTAssertEqual(headerView.statusLabel?.attributedText?.string, "Algo salió mal...".localized)
    }

    func testViewModelWithTextPreferenceAndPendingPayment() {
        let preference = PaymentResultScreenPreference()
        preference.setPending(title: pendingTitleDummy)
        preference.disablePendingLabelText()
        let paymentResult = MockBuilder.buildPaymentResult("in_process", paymentMethodId: "visa")
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil, paymentResultScreenPreference: preference)
        let headerView = buildHeaderView(resultViewModel: resultViewModel)
        let footerView = buildFooterView(resultViewModel: resultViewModel)
        let receiptView = buildReceiptView(resultViewModel: resultViewModel)
        let topCustomComponent = resultViewModel.getTopCustomComponent()
        let bottomCustomComponent = resultViewModel.getBottomCustomComponent()
        XCTAssertNil(topCustomComponent)
        XCTAssertNil(bottomCustomComponent)
        XCTAssertNil(receiptView.dateLabel)
        XCTAssertNil(receiptView.detailLabel)
        XCTAssertNil(footerView.principalButton)
        XCTAssertEqual(footerView.linkButton?.title(for: .normal), "Seguir comprando".localized)
        XCTAssertEqual(headerView.backgroundColor, UIColor.pxGreenMp)
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("card_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("pending_badge"))
        XCTAssertTrue(resultViewModel.isAccepted())
        XCTAssertFalse(resultViewModel.isWarning())
        XCTAssertFalse(resultViewModel.isError())
        XCTAssertEqual(headerView.statusLabel?.attributedText, nil)
        XCTAssertEqual(headerView.messageLabel?.attributedText?.string, "Estamos procesando el pago".localized)
    }

    func testViewModelWithTextPreferenceAndCallForAuth() {
        MercadoPagoContext.setLanguage(language: Languages._SPANISH)
        let preference = PaymentResultScreenPreference()
        preference.setPending(title: pendingTitleDummy)
        preference.disablePendingLabelText()
        let paymentResult = MockBuilder.buildPaymentResult("rejected", paymentMethodId: "Visa")
        paymentResult.statusDetail = RejectedStatusDetail.CALL_FOR_AUTH
        paymentResult.paymentData?.payerCost = PayerCost(installments: 1, installmentRate: 1, labels: [], minAllowedAmount: 100, maxAllowedAmount: 100, recommendedMessage: "", installmentAmount: 1, totalAmount: 100)
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil, paymentResultScreenPreference: preference)
        let headerView = buildHeaderView(resultViewModel: resultViewModel)
        let bodyView = buildBodyView(resultViewModel: resultViewModel)
        let footerView = buildFooterView(resultViewModel: resultViewModel)
        let receiptView = buildReceiptView(resultViewModel: resultViewModel)
        let topCustomComponent = resultViewModel.getTopCustomComponent()
        let bottomCustomComponent = resultViewModel.getBottomCustomComponent()
        XCTAssertNil(topCustomComponent)
        XCTAssertNil(bottomCustomComponent)
        XCTAssertNil(receiptView.dateLabel)
        XCTAssertNil(receiptView.detailLabel)
        XCTAssertEqual(footerView.principalButton?.title(for: .normal), "Pagar con otro medio".localized)
        XCTAssertEqual(footerView.linkButton?.title(for: .normal), "Cancelar pago".localized)
        XCTAssertEqual(headerView.backgroundColor, UIColor.pxOrangeMp)
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("card_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("need_action_badge"))
        XCTAssertEqual(headerView.statusLabel?.attributedText?.string, "Algo salió mal...".localized.toAttributedString().string)

        //Body
        //Error View
        guard let errorView = bodyView as? PXErrorView else {
            XCTAssertTrue(false, "The view is not of the expected class")
            return
        }
        XCTAssertNotNil(errorView.titleLabel)
        XCTAssertEqual(errorView.titleLabel?.text, "¿Qué puedo hacer?")
        XCTAssertNotNil(errorView.descriptionLabel)
        XCTAssertEqual(errorView.descriptionLabel?.text, "El teléfono está al dorso de tu tarjeta.")
        XCTAssertNotNil(errorView.actionButton)
        XCTAssertEqual(errorView.actionButton?.titleLabel?.text, "Ya hablé con Visa y me autorizó")
        XCTAssertNotNil(errorView.middleDivider)
        XCTAssertNotNil(errorView.secondaryTitleLabel)
        XCTAssertEqual(errorView.secondaryTitleLabel?.text, "¿No pudiste autorizarlo?")
        XCTAssertNotNil(errorView.bottomDivider)

        //Footer
        XCTAssertEqual(footerView.principalButton?.title(for: .normal), "Pagar con otro medio".localized)
        XCTAssertEqual(footerView.linkButton?.title(for: .normal), "Cancelar pago".localized)

        XCTAssertFalse(resultViewModel.isAccepted())
        XCTAssertTrue(resultViewModel.isWarning())
        XCTAssertFalse(resultViewModel.isError())
    }

    func testBodyWithErrorREJECTED_INSUFFICIENT_AMOUNT() {
        MercadoPagoContext.setLanguage(language: Languages._SPANISH)
        let paymentResult = MockBuilder.buildPaymentResult("rejected", paymentMethodId: "Visa")
        paymentResult.statusDetail = RejectedStatusDetail.INSUFFICIENT_AMOUNT
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil)
        let bodyView = buildBodyView(resultViewModel: resultViewModel)
        let topCustomComponent = resultViewModel.getTopCustomComponent()
        let bottomCustomComponent = resultViewModel.getBottomCustomComponent()
        guard let errorView = bodyView as? PXErrorView else {
            XCTAssertTrue(false, "The view is not of the expected class")
            return
        }
        XCTAssertNil(topCustomComponent)
        XCTAssertNil(bottomCustomComponent)
        XCTAssertNotNil(errorView.titleLabel)
        XCTAssertEqual(errorView.titleLabel?.text, "¿Qué puedo hacer?")
        XCTAssertNotNil(errorView.descriptionLabel)
        XCTAssertEqual(errorView.descriptionLabel?.text, "¡No te desanimes! Recárgala en cualquier banco o desde tu banca electrónica e inténtalo de nuevo. \n\nO si prefieres, puedes elegir otro medio de pago.")
        XCTAssertNil(errorView.actionButton)
        XCTAssertNil(errorView.middleDivider)
        XCTAssertNil(errorView.secondaryTitleLabel)
        XCTAssertNil(errorView.bottomDivider)
    }

    func testBodyWithErrorPENDING_CONTINGENCY() {
        MercadoPagoContext.setLanguage(language: Languages._PORTUGUESE)
        let paymentResult = MockBuilder.buildPaymentResult("pending", paymentMethodId: "Visa")
        paymentResult.statusDetail = PendingStatusDetail.CONTINGENCY
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil)
        let bodyView = buildBodyView(resultViewModel: resultViewModel)

        //Body
        //Error View
        guard let errorView = bodyView as? PXErrorView else {
            XCTAssertTrue(false, "The view is not of the expected class")
            return
        }
        XCTAssertNotNil(errorView.titleLabel)
        XCTAssertEqual(errorView.titleLabel?.text, "O que posso fazer?")
        XCTAssertNotNil(errorView.descriptionLabel)
        XCTAssertEqual(errorView.descriptionLabel?.text, "Em algumas horas te avisaremos por e-mail se foi aprovado.")
        XCTAssertNil(errorView.actionButton)
        XCTAssertNil(errorView.middleDivider)
        XCTAssertNil(errorView.secondaryTitleLabel)
        XCTAssertNil(errorView.bottomDivider)
    }

    func testBodyWithErrorREJECTED_DUPLICATED_PAYMENT() {
        MercadoPagoContext.setLanguage(language: Languages._PORTUGUESE)
        let paymentResult = MockBuilder.buildPaymentResult("rejected", paymentMethodId: "Visa")
        paymentResult.statusDetail = RejectedStatusDetail.DUPLICATED_PAYMENT
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil)
        let bodyView = buildBodyView(resultViewModel: resultViewModel)
        let topCustomComponent = resultViewModel.getTopCustomComponent()
        let bottomCustomComponent = resultViewModel.getBottomCustomComponent()
        guard let errorView = bodyView as? PXErrorView else {
            XCTAssertTrue(false, "The view is not of the expected class")
            return
        }
        XCTAssertNil(topCustomComponent)
        XCTAssertNil(bottomCustomComponent)
        XCTAssertNotNil(errorView.titleLabel)
        XCTAssertEqual(errorView.titleLabel?.text, "O que posso fazer?")
        XCTAssertNotNil(errorView.descriptionLabel)
        XCTAssertEqual(errorView.descriptionLabel?.text, "Não se preocupe! O seu pagamento foi efetuado com sucesso.")
        XCTAssertNil(errorView.actionButton)
        XCTAssertNil(errorView.middleDivider)
        XCTAssertNil(errorView.secondaryTitleLabel)
        XCTAssertNil(errorView.bottomDivider)
    }

    func testBodyWithErrorREJECTED_CARD_DISABLED() {
        MercadoPagoContext.setLanguage(language: Languages._PORTUGUESE)
        let paymentResult = MockBuilder.buildPaymentResult("rejected", paymentMethodId: "Mastercard")
        paymentResult.statusDetail = RejectedStatusDetail.CARD_DISABLE
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil)
        let bodyView = buildBodyView(resultViewModel: resultViewModel)
        let topCustomComponent = resultViewModel.getTopCustomComponent()
        let bottomCustomComponent = resultViewModel.getBottomCustomComponent()
        guard let errorView = bodyView as? PXErrorView else {
            XCTAssertTrue(false, "The view is not of the expected class")
            return
        }
        XCTAssertNil(topCustomComponent)
        XCTAssertNil(bottomCustomComponent)
        XCTAssertNotNil(errorView.titleLabel)
        XCTAssertEqual(errorView.titleLabel?.text, "O que posso fazer?")
        XCTAssertNotNil(errorView.descriptionLabel)
        XCTAssertEqual(errorView.descriptionLabel?.text, "Use outro meio de pagamento ou ligue para Mastercard e desbloqueie o cartão.")
        XCTAssertNil(errorView.actionButton)
        XCTAssertNil(errorView.middleDivider)
        XCTAssertNil(errorView.secondaryTitleLabel)
        XCTAssertNil(errorView.bottomDivider)
    }

    func testBodyWithErrorPENDING_REVIEW_MANUAL() {
        MercadoPagoContext.setLanguage(language: Languages._PORTUGUESE)
        let paymentResult = MockBuilder.buildPaymentResult("pending", paymentMethodId: "Mastercard")
        paymentResult.statusDetail = PendingStatusDetail.REVIEW_MANUAL
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil)
        let bodyView = buildBodyView(resultViewModel: resultViewModel)
        let topCustomComponent = resultViewModel.getTopCustomComponent()
        let bottomCustomComponent = resultViewModel.getBottomCustomComponent()
        guard let errorView = bodyView as? PXErrorView else {
            XCTAssertTrue(false, "The view is not of the expected class")
            return
        }
        XCTAssertNil(topCustomComponent)
        XCTAssertNil(bottomCustomComponent)
        XCTAssertNotNil(errorView.titleLabel)
        XCTAssertEqual(errorView.titleLabel?.text, "O que posso fazer?")
        XCTAssertNotNil(errorView.descriptionLabel)
        XCTAssertEqual(errorView.descriptionLabel?.text, "Dentro das próximas 24 horas te avisaremos por e-mail se foi aprovado.")
        XCTAssertNil(errorView.actionButton)
        XCTAssertNil(errorView.middleDivider)
        XCTAssertNil(errorView.secondaryTitleLabel)
        XCTAssertNil(errorView.bottomDivider)
    }

    func testExpandedHeader() {
        MercadoPagoContext.setLanguage(language: Languages._PORTUGUESE)
        let paymentResult = MockBuilder.buildPaymentResult("rejected", paymentMethodId: "Mastercard")
        paymentResult.statusDetail = RejectedStatusDetail.BAD_FILLED_SECURITY_CODE
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil)
        let resultViewController = PXResultViewController(viewModel: resultViewModel) { (congratsState) in

        }
        resultViewController.renderViews()
        let scrollView = resultViewController.scrollView
        let headerView = resultViewController.headerView
        let bodyView = resultViewController.bodyView
        let footerView = resultViewController.footerView
        let expectedHeaderHeight = scrollView!.frame.height - footerView!.frame.height
        XCTAssertEqual(headerView?.frame.height, expectedHeaderHeight)
        XCTAssertEqual(bodyView?.frame.height, 0)
        XCTAssertEqual(scrollView?.frame.height, resultViewController.contentView.frame.height)
    }

    func testExpandedBody() {
        MercadoPagoContext.setLanguage(language: Languages._PORTUGUESE)
        let paymentResult = MockBuilder.buildPaymentResult("rejected", paymentMethodId: "Mastercard")
        paymentResult.statusDetail = RejectedStatusDetail.OTHER_REASON
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil)
        let resultViewController = PXResultViewController(viewModel: resultViewModel) { (congratsState) in

        }
        resultViewController.renderViews()
        let scrollView = resultViewController.scrollView
        let headerView = resultViewController.headerView
        let bodyView = resultViewController.bodyView
        let footerView = resultViewController.footerView
        let expectedHeaderHeight = scrollView!.frame.height - footerView!.frame.height - bodyView!.frame.height
        let expectedBodyHeight = scrollView!.frame.height - footerView!.frame.height - headerView!.frame.height
        XCTAssertEqual(headerView?.frame.height, expectedHeaderHeight)
        XCTAssertEqual(bodyView?.frame.height, expectedBodyHeight)
        XCTAssertEqual(scrollView?.frame.height, resultViewController.contentView.frame.height)
    }

    func testBodyWithInstructions() {
        let paymentResult = MockBuilder.buildPaymentResult("pending", paymentMethodId: "rapipago")
        let paymentMethod = MockBuilder.buildPaymentMethod("rapipago")
        let instructionsInfo = MockBuilder.buildInstructionsInfo(paymentMethod: paymentMethod)
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount: 1000.0, instructionsInfo: instructionsInfo)
        let bodyView = buildBodyView(resultViewModel: resultViewModel)
        let receiptView = buildReceiptView(resultViewModel: resultViewModel)
        //Instructions View
        guard let instructionsView = bodyView as? PXInstructionsView else {
            XCTAssertTrue(false, "The view is not of the expected class")
            return
        }

        XCTAssertNil(receiptView.dateLabel)
        XCTAssertNil(receiptView.detailLabel)

        //Instructions Subtitle View
        XCTAssertNotNil(instructionsView.subtitleView)
        let subtitleView = instructionsView.subtitleView as! PXInstructionsSubtitleView
        XCTAssertEqual(subtitleView.subtitleLabel?.text, "Veja como é fácil pagar o seu produto")

        //Instructions Secondary Info View
        XCTAssertNotNil(instructionsView.secondaryInfoView)
        let secondaryInfoView = instructionsView.secondaryInfoView as! PXInstructionsSecondaryInfoView
        XCTAssertEqual(secondaryInfoView.secondaryInfoLabels?.count, 1)
        XCTAssertEqual(secondaryInfoView.secondaryInfoLabels![0].text, "Uma cópia desse boleto foi enviada ao seu e-mail -payer.email- caso você precise realizar o pagamento depois.")

        //Instructions Content View
        XCTAssertNotNil(instructionsView.contentsView)
        let contentView = instructionsView.contentsView as! PXInstructionsContentView
        XCTAssertNotNil(contentView.infoView)
        XCTAssertNotNil(contentView.referencesView)
        XCTAssertNil(contentView.tertiaryInfoView)
        XCTAssertNotNil(contentView.accreditationTimeView)
        XCTAssertNil(contentView.actionsView)

        //Info View
        let infoView = contentView.infoView as! PXInstructionsInfoView
        XCTAssertNil(infoView.titleLabel)
        XCTAssertNotNil(infoView.contentLabels)
        XCTAssertEqual(infoView.contentLabels?.count, 2)
        XCTAssertEqual(infoView.contentLabels![0].text, "1. Acesse o seu Internet Banking ou abra o aplicativo do seu banco.")
        XCTAssertEqual(infoView.contentLabels![1].text, "2. Utilize o código abaixo para realizar o pagamento.")
        XCTAssertNil(infoView.bottomDivider)

        //References View
        let referencesView = contentView.referencesView as! PXInstructionsReferencesView
        XCTAssertNil(referencesView.titleLabel)
        XCTAssertNotNil(referencesView.referencesComponents)
        XCTAssertEqual(referencesView.referencesComponents?.count, 1)
        //Reference View
        let referenceView = referencesView.referencesComponents![0] as! PXInstructionsReferenceView
        XCTAssertNotNil(referenceView.titleLabel)
        XCTAssertNotNil(referenceView.referenceLabel)
        XCTAssertEqual(referenceView.titleLabel?.text, "Número")
        XCTAssertEqual(referenceView.referenceLabel?.text, "2379 1729 0000 0400 1003 3802 6025 4607 2909 0063 3330")

        //Accreditation Time View
        let accreditationTimeView = contentView.accreditationTimeView as! PXInstructionsAccreditationTimeView
        XCTAssertNotNil(accreditationTimeView.accreditationMessageLabel)
        let text = "Assim que você pagar, será aprovado automaticamente entre 1 e 2 dias úteis, mas considere: Em caso de feriados, será identificado até às 18h do segundo dia útil subsequente ao feriado."
        let clockImage = NSTextAttachment()
        clockImage.image = MercadoPago.getImage("iconTime")
        let clockAttributedString = NSAttributedString(attachment: clockImage)
        let labelAttributedString = NSMutableAttributedString(string: String(describing: " "+text))
        labelAttributedString.insert(clockAttributedString, at: 0)
        let labelTitle = labelAttributedString

        XCTAssertEqual(accreditationTimeView.accreditationMessageLabel?.text, labelTitle.string)
        XCTAssertNil(accreditationTimeView.accreditationCommentsComponents)
    }

    func testBodyWithAllInstructionsComponents() {
        let paymentResult = MockBuilder.buildPaymentResult("pending", paymentMethodId: "rapipago")
        let instructionsInfo = MockBuilder.buildCompleteInstructionsInfo()
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount: 1000.0, instructionsInfo: instructionsInfo)
        let bodyView = buildBodyView(resultViewModel: resultViewModel)
        let receiptView = buildReceiptView(resultViewModel: resultViewModel)
        //Instructions View
        guard let instructionsView = bodyView as? PXInstructionsView else {
            XCTAssertTrue(false, "The view is not of the expected class")
            return
        }

        XCTAssertNil(receiptView.dateLabel)
        XCTAssertNil(receiptView.detailLabel)

        //Instructions Subtitle View
        XCTAssertNotNil(instructionsView.subtitleView)
        let subtitleView = instructionsView.subtitleView as! PXInstructionsSubtitleView
        XCTAssertEqual(subtitleView.subtitleLabel?.text, "Paga con estos datos")

        //Instructions Secondary Info View
        XCTAssertNotNil(instructionsView.secondaryInfoView)
        let secondaryInfoView = instructionsView.secondaryInfoView as! PXInstructionsSecondaryInfoView
        XCTAssertEqual(secondaryInfoView.secondaryInfoLabels?.count, 1)
        XCTAssertEqual(secondaryInfoView.secondaryInfoLabels![0].text, "También enviamos estos datos a tu email")

        //Instructions Content View
        XCTAssertNotNil(instructionsView.contentsView)
        let contentView = instructionsView.contentsView as! PXInstructionsContentView

        //Content View Sub components
        XCTAssertNotNil(contentView.infoView)
        XCTAssertNotNil(contentView.referencesView)
        XCTAssertNotNil(contentView.tertiaryInfoView)
        XCTAssertNotNil(contentView.accreditationTimeView)
        XCTAssertNotNil(contentView.actionsView)

        //Info View
        let infoView = contentView.infoView as! PXInstructionsInfoView
        XCTAssertNotNil(infoView.titleLabel)
        XCTAssertEqual(infoView.titleLabel?.text, "Primero sigue estos pasos en el cajero")
        XCTAssertNotNil(infoView.contentLabels)
        XCTAssertEqual(infoView.contentLabels?.count, 3)
        XCTAssertEqual(infoView.contentLabels![0].text, "1. Ingresa a Pagos")
        XCTAssertEqual(infoView.contentLabels![1].text, "2. Pagos de impuestos y servicios")
        XCTAssertEqual(infoView.contentLabels![2].text, "3. Rubro cobranzas")
        XCTAssertNotNil(infoView.bottomDivider)

        //References View
        let referencesView = contentView.referencesView as! PXInstructionsReferencesView
        XCTAssertNotNil(referencesView.titleLabel)
        XCTAssertEqual(referencesView.titleLabel?.text, "Luego te irá pidiendo estos datos")
        XCTAssertNotNil(referencesView.referencesComponents)
        XCTAssertEqual(referencesView.referencesComponents?.count, 3)
        //Reference View 0
        var referenceView = referencesView.referencesComponents![0] as! PXInstructionsReferenceView
        XCTAssertNotNil(referenceView.titleLabel)
        XCTAssertNotNil(referenceView.referenceLabel)
        XCTAssertEqual(referenceView.titleLabel?.text, "Referencia para abonar")
        XCTAssertEqual(referenceView.referenceLabel?.text, "2379 1729 0000 0400 1003 3802 6025 4607 2909 0063 3330")

        //Reference View 1
        referenceView = referencesView.referencesComponents![1] as! PXInstructionsReferenceView
        XCTAssertNotNil(referenceView.titleLabel)
        XCTAssertNotNil(referenceView.referenceLabel)
        XCTAssertEqual(referenceView.titleLabel?.text, "Concepto")
        XCTAssertEqual(referenceView.referenceLabel?.text, "MPAGO:COMPRA")

        //Reference View 2
        referenceView = referencesView.referencesComponents![2] as! PXInstructionsReferenceView
        XCTAssertNotNil(referenceView.titleLabel)
        XCTAssertNotNil(referenceView.referenceLabel)
        XCTAssertEqual(referenceView.titleLabel?.text, "Empresa")
        XCTAssertEqual(referenceView.referenceLabel?.text, "Mercado Libre - Mercado Pago")

        //Tertiary Info View
        let tertiaryInfoView = contentView.tertiaryInfoView as! PXInstructionsTertiaryInfoView
        XCTAssertNotNil(tertiaryInfoView.tertiaryInfoLabels)
        XCTAssertEqual(tertiaryInfoView.tertiaryInfoLabels?.count, 1)
        XCTAssertEqual(tertiaryInfoView.tertiaryInfoLabels![0].text, "Si pagas un fin de semana o feriado, será al siguiente día hábil.")

        //Accreditation Time View
        let accreditationTimeView = contentView.accreditationTimeView as! PXInstructionsAccreditationTimeView
        XCTAssertNotNil(accreditationTimeView.accreditationMessageLabel)
        let text = "Assim que você pagar, será aprovado automaticamente entre 1 e 2 dias úteis, mas considere: Em caso de feriados, será identificado até às 18h do segundo dia útil subsequente ao feriado."
        let clockImage = NSTextAttachment()
        clockImage.image = MercadoPago.getImage("iconTime")
        let clockAttributedString = NSAttributedString(attachment: clockImage)
        let labelAttributedString = NSMutableAttributedString(string: String(describing: " "+text))
        labelAttributedString.insert(clockAttributedString, at: 0)
        let labelTitle = labelAttributedString
        XCTAssertEqual(accreditationTimeView.accreditationMessageLabel?.text, labelTitle.string)

        //Accreditation Comment Views
        XCTAssertNotNil(accreditationTimeView.accreditationCommentsComponents)
        XCTAssertEqual(accreditationTimeView.accreditationCommentsComponents?.count, 1)
        let accreditationCommentView = accreditationTimeView.accreditationCommentsComponents![0] as! PXInstructionsAccreditationCommentView
        XCTAssertNotNil(accreditationCommentView.commentLabel)
        XCTAssertEqual(accreditationCommentView.commentLabel?.text, "Pagamentos realizados em correspondentes bancários podem ultrapassar este prazo.")

        //Actions View
        let actionsView = contentView.actionsView as! PXInstructionsActionsView
        XCTAssertNotNil(actionsView.actionsViews)
        XCTAssertEqual(actionsView.actionsViews?.count, 1)

        //Action View
        let actionView = actionsView.actionsViews![0] as! PXInstructionsActionView
        XCTAssertNotNil(actionView.actionButton)
        let actionButton = actionView.actionButton as! MPButton
        XCTAssertEqual(actionButton.titleLabel?.text, "Ir a banca en línea")
        XCTAssertEqual(actionButton.actionLink, "http://www.bancomer.com.mx")
    }

    func buildHeaderView(resultViewModel: PXResultViewModel) -> PXHeaderView {
        let props = PXHeaderProps(labelText: resultViewModel.labelTextHeader(), title: resultViewModel.titleHeader(), backgroundColor: resultViewModel.primaryResultColor(), productImage: resultViewModel.iconImageHeader(), statusImage: resultViewModel.badgeImage())
        let headerComponent = PXHeaderComponent(props: props)
        return PXHeaderRenderer().render(headerComponent)
    }

    func buildBodyView(resultViewModel: PXResultViewModel) -> PXBodyView {
        let props = resultViewModel.getBodyComponentProps()
        let bodyComponent = PXBodyComponent(props: props)
        return PXBodyRenderer().render(bodyComponent)
    }

    func buildFooterView(resultViewModel: PXResultViewModel) -> PXFooterView {
        let data = PXFooterProps(buttonAction: resultViewModel.getActionButton(), linkAction: resultViewModel.getActionLink())
        let footerComponent = PXFooterComponent(props: data)
        return PXFooterRenderer().render(footerComponent)
    }

    func buildReceiptView(resultViewModel: PXResultViewModel) -> PXReceiptView {
        let data = resultViewModel.getReceiptComponentProps()
        let receiptComponent = PXReceiptComponent(props: data)
        return PXReceiptRenderer().render(receiptComponent)
    }

    func testViewModelWithTextAndCustomComponentPreferenceAndApprovedPayment() {
        let ownComponent = TestComponent()
        let preference = PaymentResultScreenPreference()
        preference.setApprovedTopCustomComponent(ownComponent)
        preference.setApprovedBottomCustomComponent(ownComponent)
        preference.setApproved(title: approvedTitleDummy)
        preference.setApproved(labelText: approvedLabelDummy)
        preference.disableApprovedReceipt()
        let paymentResult = MockBuilder.buildPaymentResult("approved", paymentMethodId: "visa")
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil, paymentResultScreenPreference:preference)
        paymentResult.paymentData?.token = MockBuilder.buildToken()
        paymentResult.paymentData?.token?.lastFourDigits = "1234"
        let headerView = buildHeaderView(resultViewModel: resultViewModel)
        let footerView = buildFooterView(resultViewModel: resultViewModel)
        let bodyView = buildBodyView(resultViewModel: resultViewModel)
        let receiptView = buildReceiptView(resultViewModel: resultViewModel)
        let topCustomComponent = resultViewModel.getTopCustomComponent()
        let bottomCustomComponent = resultViewModel.getBottomCustomComponent()
        guard let paymentMethodView = bodyView as? PXPaymentMethodView else {
            XCTAssertTrue(false, "The view is not of the expected class")
            return
        }
        XCTAssertNotNil(topCustomComponent)
        XCTAssertNotNil(bottomCustomComponent)
        XCTAssertNil(receiptView.dateLabel)
        XCTAssertNil(receiptView.detailLabel)
        XCTAssertNotNil(paymentMethodView.paymentMethodIcon)
        XCTAssertEqual(paymentMethodView.amountTitle?.text, "$ 1.000")
        XCTAssertNil(paymentMethodView.amountDetail?.text)
        XCTAssertEqual(paymentMethodView.paymentMethodDescription?.text, "visa ending in 1234")
        XCTAssertNil(paymentMethodView.paymentMethodDetail?.text)
        XCTAssertEqual(paymentMethodView.disclaimerLabel?.text, "In your account yo will see the charge as description")
        XCTAssertNil(footerView.principalButton)
        XCTAssertEqual(footerView.linkButton?.title(for: .normal), "Seguir comprando".localized)
        XCTAssertEqual(headerView.backgroundColor, UIColor.pxGreenMp)
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("default_item_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("ok_badge"))
        XCTAssertTrue(resultViewModel.isAccepted())
        XCTAssertFalse(resultViewModel.isWarning())
        XCTAssertFalse(resultViewModel.isError())
        XCTAssertEqual(headerView.statusLabel?.attributedText?.string, approvedLabelDummy)
        XCTAssertEqual(headerView.messageLabel?.attributedText?.string, approvedTitleDummy)
    }
}

@objc public class TestComponent: NSObject, PXComponentizable {

    static public func getPreference() -> PaymentResultScreenPreference {
        let top = TestComponent()
        let bottom = TestComponent()
        let preference = PaymentResultScreenPreference()
        preference.setApprovedTopCustomComponent(top)
        //        preference.setApprovedBottomCustomComponent(bottom)
        return preference
    }

    public func render() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 100))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }
}
