//
//  PXAdditionalInfoConfiguration.swift
//  MercadoPagoSDKV4
//
//  Created by Eric Ertl on 24/07/2020.
//

import Foundation

final class PXAdditionalInfoConfiguration: NSObject, Codable {
    var flowId: String?

    init(flowId: String?) {
        self.flowId = flowId
    }

    enum PXAdditionalInfoConfigurationKeys: String, CodingKey {
        case flowId = "flow_id"
    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXAdditionalInfoConfigurationKeys.self)
        let flowId: String? = try container.decodeIfPresent(String.self, forKey: .flowId)
        self.init(flowId: flowId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXAdditionalInfoConfigurationKeys.self)
        try container.encodeIfPresent(flowId, forKey: .flowId)
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

    class func fromJSON(data: Data) throws -> PXAdditionalInfoConfiguration {
        return try JSONDecoder().decode(PXAdditionalInfoConfiguration.self, from: data)
    }
}
