//
//  PXCongratsType.swift
//  MercadoPagoSDK
//
//  Created by Daniel Alexander Silva on 8/12/20.
//

import Foundation

@objc public enum PXCongratsType: Int {
    case approved, rejected, pending, inProgress

    func getDescription() -> String {
        switch self {
        case .approved : return "APPROVED"
        case .rejected  : return "REJECTED"
        case .pending   : return "PENDING"
        case .inProgress : return "IN PROGRESS"
        }
    }
    
    func getRawValue() -> String {
        switch self {
        case .approved : return "approved"
        case .rejected  : return "rejected"
        case .pending   : return "pending"
        case .inProgress : return "in_process"
        }
    }
}
