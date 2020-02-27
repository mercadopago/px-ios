//
//  PXESCDeleteReason.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 19/02/2020.
//

import Foundation

@objc enum PXESCDeleteReason: Int, RawRepresentable {
    case INVALID_ESC
    case INVALID_FINGERPRINT
    case UNEXPECTED_TOKENIZATION_ERROR
    case REJECTED_PAYMENT
    case ESC_CAP
    case NO_ESC
    case NO_REASON

    public typealias RawValue = String

    public var rawValue: RawValue {
        switch self {
        case .INVALID_ESC: return  "invalid_esc"
        case .INVALID_FINGERPRINT: return  "invalid_fingerprint"
        case .UNEXPECTED_TOKENIZATION_ERROR: return  "unexpected_tokenization_error"
        case .ESC_CAP: return  "esc_cap"
        case .REJECTED_PAYMENT: return  "rejected_payment"
        case .NO_ESC: return  "no_esc"
        case .NO_REASON: return  "no_reason"
        }
    }

    public init(rawValue: RawValue) {
        switch rawValue {
        case "invalid_esc":
            self = .INVALID_ESC
        case "invalid_fingerprint":
            self = .INVALID_FINGERPRINT
        case "unexpected_tokenization_error":
            self = .UNEXPECTED_TOKENIZATION_ERROR
        case "esc_cap":
            self = .ESC_CAP
        case "rejected_payment":
            self = .REJECTED_PAYMENT
        case "no_esc":
            self = .NO_ESC
        case "no_reason":
            self = .NO_REASON
        default:
            self = .NO_REASON
        }
    }
}
