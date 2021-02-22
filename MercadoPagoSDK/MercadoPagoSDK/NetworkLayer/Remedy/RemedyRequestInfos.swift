//
//  RemedyRequestInfos.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 05/02/21.
//

enum RemedyRequestInfos {
    case getRemedy(String?, Bool, Data?)
}

extension RemedyRequestInfos: RequestInfos {
    var endpoint: String {
        switch self {
        case .getRemedy(_, _, _):
            return "px_mobile/v1/remedies/1234135506"
        }
    }
    
    var method: HTTPMethodType {
        .post
    }
    
    var body: Data? {
        switch self {
        case .getRemedy(_, _, let body): return body
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getRemedy(_, _, _): return nil
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .getRemedy(let privateKey, let oneTap, _):
            let key = privateKey ?? ""
            return [
            "access_token" : key,
            "one_tap" : oneTap ? "true" : "false"
        ]
        }
    }
}
