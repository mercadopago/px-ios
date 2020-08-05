//
//  PXAdditionalInfo.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 4/8/19.
//

import Foundation

final class PXAdditionalInfo: NSObject, Codable {
    var pxSummary: PXAdditionalInfoSummary?
    var pxConfiguration: PXAdditionalInfoConfiguration?
    var pxCustomTexts: PXAdditionalInfoCustomTexts?

    public init(pxSummary: PXAdditionalInfoSummary?, pxConfiguration: PXAdditionalInfoConfiguration?, pxCustomTexts: PXAdditionalInfoCustomTexts?) {
        self.pxSummary = pxSummary
        self.pxConfiguration = pxConfiguration
        self.pxCustomTexts = pxCustomTexts
    }

    public enum PXAdditionalInfoKeys: String, CodingKey {
        case pxSummary = "px_summary"
        case pxConfiguration = "px_configuration"
        case pxCustomTexts = "px_custom_texts"
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXAdditionalInfoKeys.self)
        let pxSummary: PXAdditionalInfoSummary? = try container.decodeIfPresent(PXAdditionalInfoSummary.self, forKey: .pxSummary)
        let pxConfiguration: PXAdditionalInfoConfiguration? = try container.decodeIfPresent(PXAdditionalInfoConfiguration.self, forKey: .pxConfiguration)
        let pxCustomTexts: PXAdditionalInfoCustomTexts? = try container.decodeIfPresent(PXAdditionalInfoCustomTexts.self, forKey: .pxCustomTexts)
        self.init(pxSummary: pxSummary, pxConfiguration: pxConfiguration, pxCustomTexts: pxCustomTexts)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXAdditionalInfoKeys.self)
        try container.encodeIfPresent(self.pxSummary, forKey: .pxSummary)
        try container.encodeIfPresent(self.pxConfiguration, forKey: .pxConfiguration)
        try container.encodeIfPresent(self.pxCustomTexts, forKey: .pxCustomTexts)
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

    class func fromJSON(data: Data) throws -> PXAdditionalInfo {
        return try JSONDecoder().decode(PXAdditionalInfo.self, from: data)
    }
}
