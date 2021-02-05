//
//  RequestInfos.swift
//  AndesUI
//
//  Created by Matheus Leandro Martins on 05/02/21.
//

import Foundation

enum HTTPMethodType: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
}

protocol RequestInfos {
    
    var baseURL: URL { get }
    
    var endpoint: String { get }
    
    var method: HTTPMethodType { get }
    
    var parameters: [String: Any]? { get }
    
    var parameterEncoding: ParameterEncode { get }

}

extension RequestInfos {
    var baseURL: URL {
        return URL(string: "https://api.mercadolibre.com/sites/MLA/")!
    }
    
    var parameterEncoding: ParameterEncode {
        return ParameterEncodingImpl()
    }
}
