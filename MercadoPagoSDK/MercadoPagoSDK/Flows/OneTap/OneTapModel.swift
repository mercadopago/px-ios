//
//  OneTapModel.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 23/06/21.
//

import Foundation

struct OneTapModel {
    let publicKey: String //
    let privateKey: String? //
    let siteId: String //
    let excludedPaymentTypeIds: [String]
    let expressData: [PXOneTapDto]? //
    let paymentMethods: [PXPaymentMethod] //
    let items: [PXItem] //
    let payerCompliance: PXPayerCompliance? //
    let modals: [String: PXModal]? //
    let payerPaymentMethods: [PXCustomOptionSearchItem] //
    let experiments: [PXExperiment]? //
    let splitPaymentEnabled: Bool = false
    let additionalInfoSummary: PXAdditionalInfoSummary? //
    let disabledOption: PXDisabledOption?
    var splitPaymentSelectionByUser: Bool? = false
    
    // MARK: - Initialization
    init(paymentInfos: PXInitDTO, disabledOption: PXDisabledOption?, excludedPaymentTypeIds: [String], publicKey: String, privateKey: String?) {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.siteId = paymentInfos.preference?.siteId ?? ""
        self.excludedPaymentTypeIds = excludedPaymentTypeIds
        self.expressData = paymentInfos.oneTap
        self.paymentMethods = paymentInfos.availablePaymentMethods
        self.items = paymentInfos.preference?.items ?? []
        self.payerCompliance = paymentInfos.payerCompliance
        self.modals = paymentInfos.modals
        self.payerPaymentMethods = paymentInfos.payerPaymentMethods
        self.experiments = paymentInfos.experiments
        self.additionalInfoSummary = paymentInfos.preference?.pxAdditionalInfo?.pxSummary
        self.disabledOption = disabledOption
    }
}
