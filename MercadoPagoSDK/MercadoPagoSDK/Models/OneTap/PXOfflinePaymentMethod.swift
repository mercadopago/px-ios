//
//  PXOfflinePaymentMethod.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 18/12/2019.
//

import Foundation

public class PXOfflinePaymentMethod: Codable {
    let id: String
    let name: PXText?
    let description: PXText?
    let imageUrl: String?
    let hasAdditionalInfoNeeded: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageUrl = "image_url"
        case hasAdditionalInfoNeeded = "has_additional_info_needed"
    }
}

extension PXOfflinePaymentMethod: PaymentMethodOption {
    func getId() -> String {
        return id
    }

    func getDescription() -> String {
        return name?.message ?? ""
    }

    func getComment() -> String {
        return description?.message ?? ""
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
        return "ticket"
    }
}
