//
//  CardFormParameters.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 02/07/21.
//

import Foundation

struct CardFormParameters {
    let privateKey: String?
    let publicKey: String
    let siteId: String
    let excludedPaymentTypeIds: [String]
}
