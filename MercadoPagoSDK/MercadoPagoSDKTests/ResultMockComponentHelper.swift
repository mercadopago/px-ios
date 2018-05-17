//
//  ResultMockComponentHelper.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 1/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
public class ResultMockComponentHelper: NSObject {

    static let approvedTitleDummy = "ATD"
    static let rejectedTitleDummy = "RTD"
    static let pendingTitleDummy = "PTD"
    static let approvedLabelDummy = "ALD"

    static func buildResultViewModel(status: String = "approved", statusDetail: String = "detail", paymentMethodId: String = "visa", paymentTypeId: String = "credit_card", preference: PaymentResultScreenPreference = PaymentResultScreenPreference(), instructionsInfo: InstructionsInfo? = nil) -> PXResultViewModel {
        let paymentResult = MockBuilder.buildPaymentResult(status, statusDetail: statusDetail, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId)
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount: 1000.0, instructionsInfo: instructionsInfo, paymentResultScreenPreference: preference)
        return resultViewModel
    }

    static func buildResultViewModelWithPreference(status: String = "approved", statusDetail: String = "detail", paymentMethodId: String = "visa", paymentTypeId: String = "credit_card") -> PXResultViewModel {

        let preference = PaymentResultScreenPreference()
        let ownComponent = TestComponent()
        preference.setApproved(title: ResultMockComponentHelper.approvedTitleDummy)
        preference.setApproved(labelText: ResultMockComponentHelper.approvedLabelDummy)
        preference.setRejected(title: ResultMockComponentHelper.rejectedTitleDummy)
        preference.setPending(title: ResultMockComponentHelper.pendingTitleDummy)
        preference.disableApprovedReceipt()
        preference.setApprovedTopCustomComponent(ownComponent)
        preference.setApprovedBottomCustomComponent(ownComponent)

        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: status, statusDetail: statusDetail, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId, preference: preference)
        return resultViewModel
    }

    static func buildResultViewModelWithInstructionInfo(completed: Bool = false) -> PXResultViewModel {
        let paymentMethod = MockBuilder.buildPaymentMethod("rapipago")
        var instructionsInfo: InstructionsInfo

        if completed {
            instructionsInfo = MockBuilder.buildCompleteInstructionsInfo()
        } else {
            instructionsInfo = MockBuilder.buildInstructionsInfo(paymentMethod: paymentMethod)
        }
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "pending", paymentMethodId: "rapipago", paymentTypeId: "ticket", instructionsInfo: instructionsInfo)
        return resultViewModel
    }

    // Mark: Header builders
    static func buildHeaderView(resultViewModel: PXResultViewModel) -> PXHeaderView {
        let headerComponent = resultViewModel.buildHeaderComponent()
        return PXHeaderRenderer().render(headerComponent)
    }

    // Mark: Body builders
    static func buildBodyView(resultViewModel: PXResultViewModel) -> UIView? {
        if let bodyComponentizable = resultViewModel.buildBodyComponent(), let bodyComponent = bodyComponentizable as? PXBodyComponent {
            return PXBodyRenderer().render(bodyComponent)
        }
        return nil
    }

    // Mark: Footer builders
    static func buildFooterView(resultViewModel: PXResultViewModel) -> PXFooterView {
        let footerComponent = resultViewModel.buildFooterComponent()
        return PXFooterRenderer().render(footerComponent)
    }

    // Mark: receipt builders
    static func buildReceiptView(resultViewModel: PXResultViewModel) -> PXReceiptView? {
        if let receiptComponent = resultViewModel.buildReceiptComponent() {
            return PXReceiptRenderer().render(receiptComponent)
        }
        return nil
    }

    // Mark: Custom component builders

    static func buildTopCustomComponent(resultViewModel: PXResultViewModel) -> PXCustomComponentizable? {
        let topCustomComponent = resultViewModel.buildTopCustomComponent()
        return topCustomComponent
    }

    static func buildBottomCustomComponent(resultViewModel: PXResultViewModel) -> PXCustomComponentizable? {
        let bottomCustomComponent = resultViewModel.buildBottomCustomComponent()
        return bottomCustomComponent
    }
}
