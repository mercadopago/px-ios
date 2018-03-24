//
//  PXBodyComponentTest.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 1/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import XCTest

class PXBodyComponentTest: BaseTest {

    // MARK: APPROVED - CARD
    func testBodyView_approvedCardPayment_render() throws {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel()

        // When:
        let bodyView = ResultMockComponentHelper.buildBodyView(resultViewModel: resultViewModel)
        let paymentMethodView = try require(bodyView as? PXPaymentMethodView)

        // Then:
        XCTAssertNotNil(paymentMethodView.paymentMethodIcon)
        XCTAssertEqual(paymentMethodView.titleLabel?.text, "$ 1.000")
        XCTAssertEqual(paymentMethodView.subtitleLabel?.text, nil)
        XCTAssertEqual(paymentMethodView.descriptionTitleLabel?.text?.localized, "visa " + "terminada en ".localized + "1234")
        XCTAssertEqual(paymentMethodView.descriptionDetailLabel?.text, "name")
        XCTAssertEqual(paymentMethodView.disclaimerLabel?.text?.localized, "En tu estado de cuenta verás el cargo como %0".localized.replacingOccurrences(of: "%0", with: "description"))
    }

    // MARK: APPROVED - ACCOUNT MONEY
    func testBodyView_approvedAccountMoney_render() throws {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(paymentMethodId: "account_money", paymentTypeId: "account_money")

        // When:
        let bodyView = ResultMockComponentHelper.buildBodyView(resultViewModel: resultViewModel)
        let paymentMethodView = try require(bodyView as? PXPaymentMethodView)

        // Then:
        XCTAssertNotNil(paymentMethodView.paymentMethodIcon)
        XCTAssertEqual(paymentMethodView.titleLabel?.text, "$ 1.000")
        XCTAssertNil(paymentMethodView.subtitleLabel?.text)
        XCTAssertEqual(paymentMethodView.descriptionTitleLabel?.text, "account_money")
        XCTAssertNil(paymentMethodView.descriptionDetailLabel?.text)
        XCTAssertEqual(paymentMethodView.disclaimerLabel?.text?.localized, "En tu estado de cuenta verás el cargo como %0".localized.replacingOccurrences(of: "%0", with: "description"))
    }

    // MARK: REJECTED - CARD
    func testBodyView_rejectedCardPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "rejected")

        // When:
        let bodyView = ResultMockComponentHelper.buildBodyView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertEqual(bodyView?.frame.height, 0)
    }

    func testBodyView_rejectedC4AuthCardPayment_render() throws {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "rejected", statusDetail: RejectedStatusDetail.CALL_FOR_AUTH)

        // When:
        let bodyView = ResultMockComponentHelper.buildBodyView(resultViewModel: resultViewModel)
        let errorView = try require(bodyView as? PXErrorView)

        // Then:
        XCTAssertNotNil(errorView.titleLabel)
        XCTAssertEqual(errorView.titleLabel?.text, "¿Qué puedo hacer?".localized)
        XCTAssertNotNil(errorView.descriptionLabel)
        XCTAssertEqual(errorView.descriptionLabel?.text, "El teléfono está al dorso de tu tarjeta.".localized)
        XCTAssertNotNil(errorView.actionButton)
        XCTAssertEqual(errorView.actionButton?.titleLabel?.text, PXResourceProvider.getActionTextForErrorBodyForREJECTED_CALL_FOR_AUTHORIZE("visa"))
        XCTAssertNotNil(errorView.middleDivider)
        XCTAssertNotNil(errorView.secondaryTitleLabel)
        XCTAssertEqual(errorView.secondaryTitleLabel?.text, PXResourceProvider.getSecondaryTitleForErrorBodyForREJECTED_CALL_FOR_AUTHORIZE())
        XCTAssertNotNil(errorView.bottomDivider)
    }

    func testBodyView_rejectedInsufficientAmountCardPayment_render() throws {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "rejected", statusDetail: RejectedStatusDetail.INSUFFICIENT_AMOUNT)

        // When:
        let bodyView = ResultMockComponentHelper.buildBodyView(resultViewModel: resultViewModel)
        let errorView = try require(bodyView as? PXErrorView)

        // Then:
        XCTAssertNotNil(errorView.titleLabel)
        XCTAssertEqual(errorView.titleLabel?.text, "¿Qué puedo hacer?".localized)
        XCTAssertNotNil(errorView.descriptionLabel)
        XCTAssertEqual(errorView.descriptionLabel?.text, PXResourceProvider.getDescriptionForErrorBodyForREJECTED_INSUFFICIENT_AMOUNT())
        XCTAssertNil(errorView.actionButton)
        XCTAssertNil(errorView.middleDivider)
        XCTAssertNil(errorView.secondaryTitleLabel)
        XCTAssertNil(errorView.bottomDivider)
    }

    func testBodyView_rejectedDuplicatedPaymentCardPayment_render() throws {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "rejected", statusDetail: RejectedStatusDetail.DUPLICATED_PAYMENT)

        // When:
        let bodyView = ResultMockComponentHelper.buildBodyView(resultViewModel: resultViewModel)
        let errorView = try require(bodyView as? PXErrorView)

        // Then:
        XCTAssertNil(errorView.titleLabel)
        XCTAssertNotNil(errorView.descriptionLabel)
        XCTAssertEqual(errorView.descriptionLabel?.text, PXResourceProvider.getDescriptionForErrorBodyForREJECTED_DUPLICATED_PAYMENT())
        XCTAssertNil(errorView.actionButton)
        XCTAssertNil(errorView.middleDivider)
        XCTAssertNil(errorView.secondaryTitleLabel)
        XCTAssertNil(errorView.bottomDivider)
    }

    func testBodyView_rejectedCardDisableCardPayment_render() throws {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "rejected", statusDetail: RejectedStatusDetail.CARD_DISABLE)

        // When:
        let bodyView = ResultMockComponentHelper.buildBodyView(resultViewModel: resultViewModel)
        let errorView = try require(bodyView as? PXErrorView)

        // Then:
        XCTAssertNotNil(errorView.titleLabel)
        XCTAssertEqual(errorView.titleLabel?.text, "¿Qué puedo hacer?".localized)
        XCTAssertNotNil(errorView.descriptionLabel)
        XCTAssertEqual(errorView.descriptionLabel?.text, PXResourceProvider.getDescriptionForErrorBodyForREJECTED_CARD_DISABLED("visa"))
        XCTAssertNil(errorView.actionButton)
        XCTAssertNil(errorView.middleDivider)
        XCTAssertNil(errorView.secondaryTitleLabel)
        XCTAssertNil(errorView.bottomDivider)
    }

    // MARK: PENDING - CARD
    func testBodyView_pendingCardPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "in_process")

        // When:
        let bodyView = ResultMockComponentHelper.buildBodyView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertEqual(bodyView?.frame.height, 0)
    }

    func testBodyView_pendingContingencyCardPayment_render() throws {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "pending", statusDetail: PendingStatusDetail.CONTINGENCY)

        // When:
        let bodyView = ResultMockComponentHelper.buildBodyView(resultViewModel: resultViewModel)
        let errorView = try require(bodyView as? PXErrorView)

        // Then:
        XCTAssertNotNil(errorView.titleLabel)
        XCTAssertEqual(errorView.titleLabel?.text, "¿Qué puedo hacer?".localized)
        XCTAssertNotNil(errorView.descriptionLabel)
        XCTAssertEqual(errorView.descriptionLabel?.text, PXResourceProvider.getDescriptionForErrorBodyForPENDING_CONTINGENCY())
        XCTAssertNil(errorView.actionButton)
        XCTAssertNil(errorView.middleDivider)
        XCTAssertNil(errorView.secondaryTitleLabel)
        XCTAssertNil(errorView.bottomDivider)
    }

    func testBodyView_pendingReviewManualCardPayment_render() throws {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "pending", statusDetail: PendingStatusDetail.REVIEW_MANUAL)

        // When:
        let bodyView = ResultMockComponentHelper.buildBodyView(resultViewModel: resultViewModel)
        let errorView = try require(bodyView as? PXErrorView)

        // Then:
        XCTAssertNotNil(errorView.titleLabel)
        XCTAssertEqual(errorView.titleLabel?.text, "¿Qué puedo hacer?".localized)
        XCTAssertNotNil(errorView.descriptionLabel)
        XCTAssertEqual(errorView.descriptionLabel?.text, PXResourceProvider.getDescriptionForErrorBodyForPENDING_REVIEW_MANUAL())
        XCTAssertNil(errorView.actionButton)
        XCTAssertNil(errorView.middleDivider)
        XCTAssertNil(errorView.secondaryTitleLabel)
        XCTAssertNil(errorView.bottomDivider)
    }

    // MARK: Instructions
    func testBodyView_instructionsPayment_render() throws {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModelWithInstructionInfo()

        // When:
        let bodyView = ResultMockComponentHelper.buildBodyView(resultViewModel: resultViewModel)
        let instructionsView = try require(bodyView as? PXInstructionsView)

        // Then:

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

    func testBodyView_instructionsCompletePayment_render() throws {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModelWithInstructionInfo(completed: true)

        // When:
        let bodyView = ResultMockComponentHelper.buildBodyView(resultViewModel: resultViewModel)
        let instructionsView = try require(bodyView as? PXInstructionsView)

        // Then:

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

}
