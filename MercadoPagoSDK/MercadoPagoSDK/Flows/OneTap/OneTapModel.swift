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
//    let excludedPaymentTypeIds: [String]
    let expressData: [PXOneTapDto]? //
    let paymentMethods: [PXPaymentMethod] //
    let items: [PXItem] //
    let payerCompliance: PXPayerCompliance? //
    let modals: [String: PXModal]? //
    let payerPaymentMethods: [PXCustomOptionSearchItem] //
    let experiments: [PXExperiment]? //
//    let applications: [PXOneTapApplication]
//    let splitPaymentEnabled: Bool
    let additionalInfoSummary: PXAdditionalInfoSummary? //
    let disabledOption: PXDisabledOption?
//    var splitPaymentSelectionByUser: Bool?
    
    // MARK: - Initialization
    init(paymentInfos: PXInitDTO, publicKey: String, privateKey: String?) {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.paymentMethods = paymentInfos.availablePaymentMethods
        self.payerCompliance = paymentInfos.payerCompliance
        self.experiments = paymentInfos.experiments
        self.modals = paymentInfos.modals
        self.items = paymentInfos.preference?.items ?? []
        self.siteId = paymentInfos.preference?.siteId ?? ""
        self.expressData = paymentInfos.oneTap
        self.additionalInfoSummary = paymentInfos.preference?.pxAdditionalInfo?.pxSummary
        self.payerPaymentMethods = paymentInfos.payerPaymentMethods
    }
}
