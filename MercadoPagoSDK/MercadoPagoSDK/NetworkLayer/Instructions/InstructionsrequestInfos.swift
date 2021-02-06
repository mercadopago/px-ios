//
//  InstructionsrequestInfos.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 06/02/21.
//

enum InstructionsrequestInfos {
    case getInstructions(String, String?, String)
}

extension InstructionsrequestInfos: RequestInfos {
    var endpoint: String {
        switch self {
        case .getInstructions(let paymentId, _, _): return "/checkout/payments/\(paymentId)/results"
        }
    }
    
    var method: HTTPMethodType {
        return .get
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .getInstructions(_, let accessToken, let publicKey):
            if let token = accessToken {
                return [
                    "access_token" : token,
                    "public_key" : publicKey
                ]
            } else {
                return [ "public_key" : publicKey ]
            }
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }
    
    
}
