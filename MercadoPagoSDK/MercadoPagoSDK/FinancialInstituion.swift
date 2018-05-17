//
//  FinancialInstituion.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 3/9/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

@objcMembers open class FinancialInstitution: NSObject, Cellable {

    public var objectType: ObjectTypes = ObjectTypes.financialInstitution
    open var financialInstitutionId: Int?
    open var financialInstitutionDescription: String?

    open class func fromJSON(_ json: NSDictionary) -> FinancialInstitution {
        let financialInstitution: FinancialInstitution = FinancialInstitution()
        if let financialInstitutionId = JSONHandler.attemptParseToString(json["id"])?.numberValue, let finalId = financialInstitutionId as? Int {
            financialInstitution.financialInstitutionId = finalId
        }
        if let description = JSONHandler.attemptParseToString(json["description"]) {
            financialInstitution.financialInstitutionDescription = description
        }
        return financialInstitution
    }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    open func toJSON() -> [String: Any] {
        let id: Any = self.financialInstitutionId == nil ? JSONHandler.null : self.financialInstitutionId!
        let description: Any = self.financialInstitutionDescription == nil ? JSONHandler.null : self.financialInstitutionDescription!
        let obj: [String: Any] = [
            "id": id,
            "description": description
            ]
        return obj
    }
}
