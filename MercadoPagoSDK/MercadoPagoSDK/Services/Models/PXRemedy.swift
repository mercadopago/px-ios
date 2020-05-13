//
//  PXRemedy.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 16/03/2020.
//

import Foundation

struct PXRemedy: Codable {
    let cvv: PXInvalidCVV?
    let highRisk: PXHighRisk?
    let callForAuth: PXCallForAuth?
    let suggestedPaymentMethod: PXSuggestedPaymentMethod?
    let trackingData: [String: String]?
}

extension PXRemedy {
    var isEmpty: Bool {
        return cvv == nil && highRisk == nil && callForAuth == nil && suggestedPaymentMethod == nil
    }
}

struct PXInvalidCVV: Codable {
    let title: String?
    let message: String?
    let fieldSetting: PXFieldSetting?
}

struct PXHighRisk: Codable {
    let title: String?
    let message: String?
    let deepLink: String?
    let actionLoud: PXButtonAction?
}

struct PXCallForAuth: Codable {
    let title: String?
    let message: String?
}

struct PXFieldSetting: Codable {
    let name: String?
    let length: Int
    let title: String?
    let hintMessage: String?
}

struct PXButtonAction: Codable {
    let label: String?
}

struct PXSuggestedPaymentMethod: Codable {
    let title: String?
    let message: String?
    let actionLoud: PXButtonAction?
    let alternativePaymentMethod: PXRemedyPaymentMethod?
}

struct PXRemedyPaymentMethod: Codable {
    let customOptionId: String?
    let paymentMethodId: String?
    let paymentTypeId: String?
    let escStatus: String
    let issuerName: String?
    let lastFourDigit: String
    let securityCodeLocation: String?
    let securityCodeLength: Int?
    let installmentsList: [PXPaymentMethodInstallment]?
    let installment: PXPaymentMethodInstallment?
}

struct PXPaymentMethodInstallment: Codable {
    let installments: Int
    let totalAmount: Double
}
