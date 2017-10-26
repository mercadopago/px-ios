//
//  PXPaymentPreference.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPaymentPreference: NSObject, Codable {

    open var maxAcceptedInstallments: Int?
    open var defaultInstallments: Int?
    open var excludedPaymentMethodIds: [String]
    open var excludedPaymentTypeIds: [String]
    open var defaultPaymentMethodId: String?
    open var defaultPaymentTypeId: String?


    init(maxAcceptedInstallments: Int?, defaultInstallments: Int?, excludedPaymentMethodIds: [String], excludedPaymentTypeIds: [String], defaultPaymentMethodId: String?, defaultPaymentTypeId: String?) {
        self.maxAcceptedInstallments = maxAcceptedInstallments
        self.defaultInstallments = defaultInstallments
        self.excludedPaymentMethodIds = excludedPaymentMethodIds
        self.excludedPaymentTypeIds = excludedPaymentTypeIds
        self.defaultPaymentMethodId = defaultPaymentMethodId
        self.defaultPaymentTypeId = defaultPaymentTypeId
    }
    
    init(maxAcceptedInstallments: Int?, defaultInstallments: Int?, excludedPaymentMethods: [PXPaymentMethod], excludedPaymentTypes: [PXPaymentType], defaultPaymentMethodId: String?, defaultPaymentTypeId: String?) {

        var excludedPaymentTypeIds: [String] = []
        for paymentType in excludedPaymentTypes {
            if String.isNullOrEmpty(paymentType.id) {
                excludedPaymentTypeIds.append(paymentType.id)
            }
        }

        var excludedPaymentMethodIds: [String] = []
        for paymentMethod in excludedPaymentMethods {
            if String.isNullOrEmpty(paymentMethod.id) {
                excludedPaymentMethodIds.append(paymentMethod.id)
            }
        }

        self.maxAcceptedInstallments = maxAcceptedInstallments
        self.defaultInstallments = defaultInstallments
        self.excludedPaymentMethodIds = excludedPaymentMethodIds
        self.excludedPaymentTypeIds = excludedPaymentTypeIds
        self.defaultPaymentMethodId = defaultPaymentMethodId
        self.defaultPaymentTypeId = defaultPaymentTypeId
    }

    public enum PXPaymentPreferenceKeys: String, CodingKey {
        case maxAcceptedInstallments = "installments"
        case defaultInstallments = "default_installments"
        case excludedPaymentMethodIds = "excluded_payment_methods"
        case excludedPaymentTypeIds = "excluded_payment_types"
        case defaultPaymentMethodId = "default_payment_method_id"
        case defaultPaymentTypeId = "default_payment_type_id"
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXPaymentPreferenceKeys.self)
        let defaultInstallments: Int? = try container.decodeIfPresent(Int.self, forKey: .defaultInstallments)
        let maxAcceptedInstallments: Int? = try container.decodeIfPresent(Int.self, forKey: .maxAcceptedInstallments)
        let excludedPaymentMethods: [PXPaymentMethod] = try container.decode([PXPaymentMethod].self, forKey: .excludedPaymentMethodIds)
        let excludedPaymentTypes: [PXPaymentType] = try container.decode([PXPaymentType].self, forKey: .excludedPaymentTypeIds)
        let defaultPaymentMethodId: String? = try container.decodeIfPresent(String.self, forKey: .defaultPaymentMethodId)
        let defaultPaymentTypeId: String? = try container.decodeIfPresent(String.self, forKey: .defaultPaymentTypeId)


        self.init(maxAcceptedInstallments: maxAcceptedInstallments, defaultInstallments: defaultInstallments, excludedPaymentMethods: excludedPaymentMethods, excludedPaymentTypes: excludedPaymentTypes, defaultPaymentMethodId: defaultPaymentMethodId, defaultPaymentTypeId: defaultPaymentTypeId)
    }

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open class func fromJSON(data: Data) throws -> PXPaymentPreference {
        return try JSONDecoder().decode(PXPaymentPreference.self, from: data)
    }

}
