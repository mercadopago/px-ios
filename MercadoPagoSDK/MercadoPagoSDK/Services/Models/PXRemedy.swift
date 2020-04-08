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
    let suggestionPaymentMethod: PXSuggestionPaymentMethod?
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

struct PXSuggestionPaymentMethod: Codable {
    let title: String?
    let message: String?
    let alternativePayerPaymentMethod: PXAlternativePayerPaymentMethod?
}

struct PXAlternativePayerPaymentMethod: Codable {
    let paymentMethodId: String
    let paymentTypeId: String
    let installments: [PXPaymentMethodInstallment]?
    let selectedPayerCostIndex: Int
    let esc: Bool
}

struct PXPaymentMethodInstallment: Codable {
    let installments: Int
    let totalAmount: Double
    let labels: [String]
    let recommendedMessage: String?
}
