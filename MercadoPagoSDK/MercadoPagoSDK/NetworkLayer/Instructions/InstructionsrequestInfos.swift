//
//  InstructionsrequestInfos.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 06/02/21.
//

enum InstructionsrequestInfos {
    case getInstructions(paymentId: String, paymentTypeId: String, privateKey: String?, publicKey: String)
}

extension InstructionsrequestInfos: RequestInfos {
    var endpoint: String {
        switch self {
        case .getInstructions(let paymentId, _, _, _): return "v1/checkout/payments/\(paymentId)/results"
        }
    }
    
    var method: HTTPMethodType {
        return .get
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .getInstructions(_, let paymentId, let accessToken, let publicKey):
            if let token = accessToken {
                return [
                    "access_token" : token,
                    "public_key" : publicKey,
                    "payment_type" : paymentId
                ]
            } else {
                return [
                    "public_key" : publicKey,
                    "payment_type" : paymentId
                ]
            }
        }
    }
    
    var shouldSetEnvironment: Bool {
        return false
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }
}
