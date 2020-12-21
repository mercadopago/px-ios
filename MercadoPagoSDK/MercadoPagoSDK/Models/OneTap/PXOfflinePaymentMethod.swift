//
//  PXOfflinePaymentMethod.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 18/12/2019.
//

import Foundation

public class PXOfflinePaymentMethod: Codable {
    let id: String
    let instructionId: String
    let name: PXText?
    let imageUrl: String
    let description: PXText?
    let hasAdditionalInfoNeeded: Bool
    let status: PXStatus

    enum CodingKeys: String, CodingKey {
        case id
        case instructionId = "instruction_id"
        case name
        case imageUrl = "image_url"
        case description
        case hasAdditionalInfoNeeded = "has_additional_info_needed"
        case status
    }
}

extension PXOfflinePaymentMethod: PaymentMethodOption {
    func getId() -> String {
        return id
    }

    func hasChildren() -> Bool {
        return false
    }

    func getChildren() -> [PaymentMethodOption]? {
        return nil
    }

    func isCard() -> Bool {
        return false
    }

    func isCustomerPaymentMethod() -> Bool {
        return false
    }

    func getPaymentType() -> String {
        return ""
    }

    func additionalInfoNeeded() -> Bool {
        return hasAdditionalInfoNeeded
    }
}
