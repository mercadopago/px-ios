//
//  PXAdditionalInfoCustomTexts.swift
//  MercadoPagoSDKV4
//
//  Created by Eric Ertl on 24/07/2020.
//

import Foundation

final class PXAdditionalInfoCustomTexts: NSObject, Codable {
    var payButton: String?
    var payButtonProgress: String?
    var totalDescription: String?

    init(payButton: String?, payButtonProgress: String?, totalDescription: String?) {
        self.payButton = payButton
        self.payButtonProgress = payButtonProgress
        self.totalDescription = totalDescription
    }

    enum PXAdditionalInfoCustomTextsKeys: String, CodingKey {
        case payButton = "pay_button"
        case payButtonProgress = "pay_button_progress"
        case totalDescription = "total_description"
    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXAdditionalInfoCustomTextsKeys.self)
        let payButton: String? = try container.decodeIfPresent(String.self, forKey: .payButton)
        let payButtonProgress: String? = try container.decodeIfPresent(String.self, forKey: .payButtonProgress)
        let totalDescription: String? = try container.decodeIfPresent(String.self, forKey: .totalDescription)
        self.init(payButton: payButton, payButtonProgress: payButtonProgress, totalDescription: totalDescription)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXAdditionalInfoCustomTextsKeys.self)
        try container.encodeIfPresent(payButton, forKey: .payButton)
        try container.encodeIfPresent(payButtonProgress, forKey: .payButtonProgress)
        try container.encodeIfPresent(totalDescription, forKey: .totalDescription)
    }

    func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    class func fromJSON(data: Data) throws -> PXAdditionalInfoCustomTexts {
        return try JSONDecoder().decode(PXAdditionalInfoCustomTexts.self, from: data)
    }
}
