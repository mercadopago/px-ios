//
//  PXInstruction.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXInstruction: NSObject, Codable {
    open var title: String!
    open var subtitle: String!
    open var accreditationMessage: String!
    open var acceditationComments: [String]!
    open var action: [PXInstructionAction]!
    open var type: String!
    open var references: [PXInstructionReference]!
    open var secondaryInfo: [String]!
    open var tertiaryInfo: [String]!
    open var info: [String]!

    init(title: String, subtitle: String, accreditationMessage: String, acceditationComments: [String], action: [PXInstructionAction], type: String, references: [PXInstructionReference], secondaryInfo: [String], tertiaryInfo: [String], info: [String]) {
        self.title = title
        self.subtitle = subtitle
        self.accreditationMessage = accreditationMessage
        self.acceditationComments = acceditationComments
        self.action = action
        self.type = type
        self.references = references
        self.secondaryInfo = secondaryInfo
        self.tertiaryInfo = tertiaryInfo
        self.info = info
    }

    public enum PXInstructionKeys: String, CodingKey {
        case title
        case subtitle
        case accreditationMessage = "accreditation_message"
        case acceditationComments = "acceditation_comments"
        case action
        case type
        case references
        case secondaryInfo = "secondary_info"
        case tertiaryInfo = "tertiary_info"
        case info
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXInstructionKeys.self)
        let title: String = try container.decode(String.self, forKey: .title)
        let subtitle: String = try container.decode(String.self, forKey: .subtitle)
        let accreditationMessage: String = try container.decode(String.self, forKey: .accreditationMessage)
        let acceditationComments: [String] = try container.decode([String].self, forKey: .acceditationComments)
        let action: [PXInstructionAction] = try container.decode([PXInstructionAction].self, forKey: .action)
        let type: String = try container.decode(String.self, forKey: .type)
        let references: [PXInstructionReference] = try container.decode([PXInstructionReference].self, forKey: .references)
        let secondaryInfo: [String] = try container.decode([String].self, forKey: .secondaryInfo)
        let tertiaryInfo: [String] = try container.decode([String].self, forKey: .tertiaryInfo)
        let info: [String] = try container.decode([String].self, forKey: .info)

        self.init(title: title, subtitle: subtitle, accreditationMessage: accreditationMessage, acceditationComments: acceditationComments, action: action, type: type, references: references, secondaryInfo: secondaryInfo, tertiaryInfo: tertiaryInfo, info: info)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXInstructionKeys.self)
        try container.encodeIfPresent(self.title, forKey: .title)
        try container.encodeIfPresent(self.subtitle, forKey: .subtitle)
        try container.encodeIfPresent(self.accreditationMessage, forKey: .accreditationMessage)
        try container.encodeIfPresent(self.acceditationComments, forKey: .acceditationComments)
        try container.encodeIfPresent(self.action, forKey: .action)
        try container.encodeIfPresent(self.type, forKey: .type)
        try container.encodeIfPresent(self.references, forKey: .references)
        try container.encodeIfPresent(self.secondaryInfo, forKey: .secondaryInfo)
        try container.encodeIfPresent(self.tertiaryInfo, forKey: .tertiaryInfo)
        try container.encodeIfPresent(self.info, forKey: .info)
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

    open class func fromJSON(data: Data) throws -> PXInstruction {
        return try JSONDecoder().decode(PXInstruction.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXInstruction] {
        return try JSONDecoder().decode([PXInstruction].self, from: data)
    }

}
