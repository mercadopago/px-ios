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
    let paymentMethod: PXRemedyPaymentMethod?
}

struct PXRemedyPaymentMethod: Codable {
    let customOptionId: String
    let paymentMethodId: String
    let paymentTypeId: String
    let installment: PXPaymentMethodInstallment?
    let escStatus: String
}

struct PXAlternativePayerPaymentMethod: Codable {
    let paymentMethodId: String
    let paymentTypeId: String
    let installments: [PXPaymentMethodInstallment]?
    let escStatus: String
}

struct PXPaymentMethodInstallment: Codable {
    let installments: Int
    let totalAmount: Double
    let labels: [String]
    let recommendedMessage: String?
}
