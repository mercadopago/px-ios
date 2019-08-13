//
//  PXInitCheckoutParams.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 11/08/2019.
//

import Foundation

struct PXInitCheckoutParams: Codable {

    let discountParamsConfiguration: PXInitDiscountParamsConfiguration
    let cardsWithEsc: [String]
    let charges: [String]
    let supportsSplit: Bool
    let supportsExpress: Bool
    let shouldSkipUserConfirmation: Bool
    let dynamicDialogLocations: [String]
    let dynamicViewLocations: [String]

    public enum PXInitCheckoutParamsCodingKeys: String, CodingKey {
        case discountParamsConfiguration = "discount_params_configuration"
        case cardsWithEsc = "cards_with_esc"
        case charges
        case supportsSplit = "supports_split"
        case supportsExpress = "supports_express"
        case shouldSkipUserConfirmation = "should_skip_user_confirmation"
        case dynamicDialogLocations = "dynamic_dialog_locations"
        case dynamicViewLocations = "dynamic_view_locations"
    }

    public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: PXInitCheckoutParamsCodingKeys.self)
            try container.encodeIfPresent(self.discountParamsConfiguration, forKey: .discountParamsConfiguration)
            try container.encodeIfPresent(self.cardsWithEsc, forKey: .cardsWithEsc)
            try container.encodeIfPresent(self.charges, forKey: .charges)
            try container.encodeIfPresent(self.supportsSplit, forKey: .supportsSplit)
            try container.encodeIfPresent(self.supportsExpress, forKey: .supportsExpress)
            try container.encodeIfPresent(self.shouldSkipUserConfirmation, forKey: .shouldSkipUserConfirmation)
            try container.encodeIfPresent(self.dynamicDialogLocations, forKey: .dynamicDialogLocations)
            try container.encodeIfPresent(self.dynamicViewLocations, forKey: .dynamicViewLocations)
        }
}
