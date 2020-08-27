//
//  PXCongratsType.swift
//  MercadoPagoSDK
//
//  Created by Daniel Alexander Silva on 8/12/20.
//

import Foundation

@objc public enum PXCongratsType: Int {
    /**
     APPROVED payment.
     */
    case APPROVED
    /**
     REJECTED payment.
     */
    case REJECTED
    /**
     PENDING payment.
     */
    case PENDING
    /**
     IN_PROGRESS payment.
     */
    case IN_PROGRESS

    func getDescription() -> String {
        switch self {
        case .APPROVED : return "APPROVED"
        case .REJECTED  : return "REJECTED"
        case .PENDING   : return "PENDING"
        case .IN_PROGRESS : return "IN PROGRESS"
        }
    }
    
    func getRawValue() -> String {
        switch self {
        case .APPROVED : return "approved"
        case .REJECTED  : return "rejected"
        case .PENDING   : return "pending"
        case .IN_PROGRESS : return "in_process"
        }
    }
}
