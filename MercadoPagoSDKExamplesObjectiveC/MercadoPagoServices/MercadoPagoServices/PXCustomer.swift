//
//  PXCustomer.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXCustomer: NSObject {
    open var address: PXAddress!
    open var card: [PXCard]!
    open var defaultCard: String!
    open var _description: String!
    open var dateCreated: Date!
    open var dateLastUpdated: Date!
    open var email: String!
    open var firstName: String!
    open var id: String!
    open var identification: PXIdentification!
    open var lastName: String!
    open var liveMode: Bool!
    open var metadata: [String: String]!
    open var phone: PXPhone!
    open var registrationDate: Date!
    
    open class func fromJSON(_ json: NSDictionary) -> PXCustomer {
        let customer: PXCustomer = PXCustomer()
        return customer
    }
}
