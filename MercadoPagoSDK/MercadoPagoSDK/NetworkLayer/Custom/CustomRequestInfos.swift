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
        case .getPointsAndDiscounts(_, let parameters): return organizeParameters(parameters: parameters)
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
        case .resetESCCap(_, _), .getPointsAndDiscounts(_, _): return nil
        case .createPayment(_, _, _, let header): return header
        }
    }
    
    var body: Data? {
        switch self {
        case .resetESCCap(_, _): return nil
        case .getPointsAndDiscounts(let data, _): return data
        case .createPayment(_, _, let data, _): return data
        }
    }
}

extension CustomRequestInfos {
    func organizeParameters(parameters: CustomParametersModel) -> [String : Any] {
        var filteredParameters: [String : Any] = [:]
        
        if parameters.paymentMethodIds != "" {
            filteredParameters.updateValue(parameters.paymentMethodIds, forKey: "payment_methods_ids")
        }
        
        if parameters.paymentiDS != "" {
            filteredParameters.updateValue(parameters.paymentiDS, forKey: "payment_ids")
        }
        
        if let prefId = parameters.prefId {
            filteredParameters.updateValue(prefId, forKey: "pref_id")
        }
        
        if let campaignId = parameters.campaignId {
            filteredParameters.updateValue(campaignId, forKey: "campaign_id")
        }
        
        if let flowName = parameters.flowName {
            filteredParameters.updateValue(flowName, forKey: "flow_name")
        }
        
        if let merchantOrderId = parameters.merchantOrderId {
            filteredParameters.updateValue(merchantOrderId, forKey: "merchant_order_id")
        }
        
        filteredParameters.updateValue("2.0", forKey: "api_version")
        filteredParameters.updateValue(parameters.ifpe, forKey: "ifpe")
        
        return filteredParameters
    }
}
