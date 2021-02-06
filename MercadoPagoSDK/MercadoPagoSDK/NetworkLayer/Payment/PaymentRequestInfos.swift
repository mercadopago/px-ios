//
//  PaymentRequestInfos.swift
//  AndesUI
//
//  Created by Matheus Leandro Martins on 05/02/21.
//

import Foundation

enum PaymentRequestInfos {
    case getInit(String?, String?, Data?, [String: String]?)
}

extension PaymentRequestInfos: RequestInfos {
    var endpoint: String {
        switch self {
        case .getInit(let preferenceId, _, _, _): return "px_mobile/v2/checkout/\(preferenceId ?? "")"
        }
    }
    
    var method: HTTPMethodType {
        .post
    }
    
    var body: Data? {
        switch self {
        case .getInit(_, _, let body, _): return body
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getInit(_, _, _, let header): return header
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .getInit(_, let accessToken, _, _):
        if let token = accessToken { return [ "access_token" : token ] } else { return nil }
        }
    }
}
