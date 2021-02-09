//
//  CustomRequestInfos.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 08/02/21.
//

enum CustomRequestInfos {
    case resetESCCap(cardId: String, privateKey: String?)
    case getPointsAndDiscounts(data: Data?, parameters: CustomParametersModel)
    case createPayment(privateKey: String?, publicKey: String, data: Data?, header: [String : String]?)
}

extension CustomRequestInfos: RequestInfos {
    var endpoint: String {
        switch self {
        case .resetESCCap(let cardId, _): return "px_mobile/v1/esc_cap/\(cardId)"
        case .getPointsAndDiscounts(_, _): return "px_mobile/congrats"
        case .createPayment(_, _, _, _): return "px_mobile/payments"
        }
    }
    
    var method: HTTPMethodType {
        switch self {
        case .resetESCCap(_, _): return .delete
        case .getPointsAndDiscounts(_, _): return .get
        case .createPayment(_, _, _, _): return .post
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .resetESCCap(_, let privateKey): if let privateKey = privateKey { return ["access_token" : privateKey] } else { return nil }
        case .getPointsAndDiscounts(_, let parameters): return [
            "payment_methods_ids" : parameters.paymentMethodIds,
            "payment_ids" : parameters.paymentiDS,
            "api_version" : "2.0",
            "ifpe" : parameters.ifpe,
            "pref_id" : parameters.prefId,
            "campaign_id" : parameters.campaignId,
            "flow_name" : parameters.flowName,
            "merchant_order_id" : parameters.merchantOrderId,
            "platform" : MLBusinessAppDataService().getAppIdentifier().rawValue
        ]
        case .createPayment(let privateKey, let publicKey, _, _):
            if let token = privateKey {
                return [
                    "access_token" : token,
                    "public_key" : publicKey,
                    "api_version" : "2.0"
                ]
            } else {
                return [
                    "public_key" : publicKey,
                    "api_version" : "2.0"
                ]
            }
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .resetESCCap(_), .getPointsAndDiscounts(_, _): return nil
        case .createPayment(_, _, _, let header): return header
        }
    }
    
    var body: Data? {
        switch self {
        case .resetESCCap(_): return nil
        case .getPointsAndDiscounts(let data, _): return data
        case .createPayment(_, _, let data, _): return data
        }
    }
}
