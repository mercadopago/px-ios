//
//  PXPayer.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPayer: NSObject, Codable {

    open var id: String?
    open var accessToken: String?
    open var identification: PXIdentification?
    open var type: String?
    open var entityType: String?
    open var email: String? // TODO: Sacar como opcional
    open var firstName: String?
    open var lastName: String?

    public init(id: String?, accessToken: String?, identification: PXIdentification?, type: String?, entityType: String?, email: String?, firstName: String?, lastName: String?) {
        self.id = id
        self.accessToken = accessToken
        self.identification = identification
        self.type = type
        self.entityType = entityType
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
    }

    public enum PXPayerKeys: String, CodingKey {
        case id
        case accessToken = "access_token"
        case identification = "identification"
        case type
        case entityType = "entity_type"
        case email = "email"
        case firstName = "first_name"
        case lastName = "last_name"
    }

    required public convenience init(from decoder: Decoder) throws {
//        let algo = try! decoder.unkeyedContainer()
//        print(algo)
        let container = try decoder.container(keyedBy: PXPayerKeys.self)
        let accessToken: String? = try container.decodeIfPresent(String.self, forKey: .accessToken)
        let type: String? = try container.decodeIfPresent(String.self, forKey: .type)
        let email: String =  try container.decode (String.self, forKey: .email)
        let id: String? = try container.decodeIfPresent(String.self, forKey: .id)
        let entityType: String? = try container.decodeIfPresent(String.self, forKey: .entityType)
        let firstName: String? = try container.decodeIfPresent(String.self, forKey: .firstName)
        let lastName: String? = try container.decodeIfPresent(String.self, forKey: .lastName)
        let identification: PXIdentification? = try container.decodeIfPresent(PXIdentification.self, forKey: .identification)


        self.init(id: id, accessToken: accessToken, identification: identification, type: type, entityType: entityType, email: email, firstName: firstName, lastName: lastName)
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

    open class func fromJSON(data: Data) throws -> PXPayer {
        return try JSONDecoder().decode(PXPayer.self, from: data)
    }
}
