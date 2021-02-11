//
//  RequestProtocol.swift
//  AndesUI
//
//  Created by Matheus Leandro Martins on 05/02/21.
//

import Foundation

protocol RequestProtocol {
    associatedtype
    Target: RequestInfos
    func requestObject<Model: Codable>(model: Model.Type, _ target: Target, completionHandler: @escaping (_ result: Model?, _ error: Error?) -> Void)
    func requestArray<Model: Codable>(model: Model.Type, _ target: Target, completionHandler: @escaping (_ result: [Model]?, _ error: Error?) -> Void)
    func requestData(target: Target, completionHandler: @escaping (_ data: Data?, _ error: Error?) -> Void)
}

final class Requesting<Target: RequestInfos> : RequestProtocol {
    let MP_DEFAULT_PRODUCT_ID = "BJEO9TFBF6RG01IIIOU0"
    //MARK: - Public methods
    func requestObject<Model>(model: Model.Type, _ target: Target, completionHandler: @escaping (Model?, Error?) -> Void) where Model : Codable {
        guard let url = URL(string: "\(target.baseURL)\(target.shouldSetEnvironment ?  target.environment.rawValue : "")\(target.endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            completionHandler(nil, NSError())
            return
        }
        
        var request = URLRequest(url: url)
        
        if let headers = target.headers {
            for header in headers {
                request.setValue(header.key, forHTTPHeaderField: header.value)
            }
        }
    
        do {
            request = try target.parameterEncoding.encode(request: URLRequest(url: url), parameters: target.parameters)
        } catch {
            completionHandler(nil, NSError())
        }
        
        request.httpBody = target.body
        request.httpMethod = target.method.rawValue
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 15.0
        
        request.setValue("application/json", forHTTPHeaderField: MercadoPagoService.HeaderField.contentType.rawValue)
        if let sdkVersion = MercadoPagoBundle.bundleShortVersionString() {
            let value = "PX/iOS/" + sdkVersion
            request.setValue(value, forHTTPHeaderField: MercadoPagoService.HeaderField.userAgent.rawValue)
        }
        
        // Add session id
        request.setValue(MPXTracker.sharedInstance.getRequestId(), forHTTPHeaderField: MercadoPagoService.HeaderField.requestId.rawValue)
        request.setValue(MPXTracker.sharedInstance.getSessionID(), forHTTPHeaderField: MercadoPagoService.HeaderField.sessionId.rawValue)

        // Language
        request.setValue(Localizator.sharedInstance.getLanguage(), forHTTPHeaderField: MercadoPagoService.HeaderField.language.rawValue)

        //Density Header
        request.setValue("xxxhdpi", forHTTPHeaderField: MercadoPagoService.HeaderField.density.rawValue)

        //Product ID Header
        if target.headers?[MercadoPagoService.HeaderField.productId.rawValue] == nil {
            request.setValue(MP_DEFAULT_PRODUCT_ID, forHTTPHeaderField: MercadoPagoService.HeaderField.productId.rawValue)
        }

        // Add platform
        request.setValue(MLBusinessAppDataService().getAppIdentifier().rawValue, forHTTPHeaderField: MercadoPagoService.HeaderField.platform.rawValue)
        
        // Add flow id
        request.setValue(MPXTracker.sharedInstance.getFlowName() ?? "unknown", forHTTPHeaderField: MercadoPagoService.HeaderField.flowId.rawValue)

        if let headers = target.headers {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        URLSession.shared.dataTask(with: request) { data, resp, error in
            if let error = error {
                completionHandler(nil, error)
            }
            
            guard let data = data else {
                completionHandler(nil, NSError())
                return
            }
            
            do {
                let modelList = try JSONDecoder().decode(Model.self , from: data)
                completionHandler(modelList, nil)
            } catch {
                completionHandler(nil, NSError())
            }
        }.resume()
    }
    
    func requestArray<Model: Codable>(model: Model.Type, _ target: Target, completionHandler: @escaping (_ result: [Model]?, _ error: Error?) -> Void) {
        guard let url = URL(string: "\(target.baseURL)\(target.environment.rawValue)\(target.endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            completionHandler(nil, NSError())
            return
        }
        
        var request = URLRequest(url: url)
        
        do {
            request = try target.parameterEncoding.encode(request: URLRequest(url: url), parameters: target.headers)
        } catch {
            completionHandler(nil, NSError())
        }
        
        do {
            request = try target.parameterEncoding.encode(request: URLRequest(url: url), parameters: target.parameters)
        } catch {
            completionHandler(nil, NSError())
        }
        
        request.httpBody = target.body
        request.httpMethod = target.method.rawValue
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 15.0
        
        request.setValue("application/json", forHTTPHeaderField: MercadoPagoService.HeaderField.contentType.rawValue)
        if let sdkVersion = MercadoPagoBundle.bundleShortVersionString() {
            let value = "PX/iOS/" + sdkVersion
            request.setValue(value, forHTTPHeaderField: MercadoPagoService.HeaderField.userAgent.rawValue)
        }

        // Add session id
        request.setValue(MPXTracker.sharedInstance.getRequestId(), forHTTPHeaderField: MercadoPagoService.HeaderField.requestId.rawValue)
        request.setValue(MPXTracker.sharedInstance.getSessionID(), forHTTPHeaderField: MercadoPagoService.HeaderField.sessionId.rawValue)

        // Language
        request.setValue(Localizator.sharedInstance.getLanguage(), forHTTPHeaderField: MercadoPagoService.HeaderField.language.rawValue)

        //Density Header
        request.setValue("xxxhdpi", forHTTPHeaderField: MercadoPagoService.HeaderField.density.rawValue)

        //Product ID Header
        if target.headers?[MercadoPagoService.HeaderField.productId.rawValue] == nil {
            request.setValue(MP_DEFAULT_PRODUCT_ID, forHTTPHeaderField: MercadoPagoService.HeaderField.productId.rawValue)
        }

        // Add platform
        request.setValue(MLBusinessAppDataService().getAppIdentifier().rawValue, forHTTPHeaderField: MercadoPagoService.HeaderField.platform.rawValue)
        
        // Add flow id
        request.setValue(MPXTracker.sharedInstance.getFlowName() ?? "unknown", forHTTPHeaderField: MercadoPagoService.HeaderField.flowId.rawValue)

        if let headers = target.headers {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        URLSession.shared.dataTask(with: request) { data, resp, error in
            if let error = error {
                completionHandler(nil, error)
            }
            
            guard let data = data else {
                completionHandler(nil, NSError())
                return
            }
            
            do {
                let modelList = try JSONDecoder().decode([Model].self , from: data)
                completionHandler(modelList, nil)
            } catch {
                completionHandler(nil, NSError())
            }
        }.resume()
    }
    
    func requestData(target: Target, completionHandler: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        guard let url = URL(string: "\(target.baseURL)\(target.environment.rawValue)\(target.endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            completionHandler(nil, NSError())
            return
        }
        
        var request = URLRequest(url: url)
        
        do {
            request = try target.parameterEncoding.encode(request: URLRequest(url: url), parameters: target.headers)
        } catch {
            completionHandler(nil, NSError())
        }
        
        do {
            request = try target.parameterEncoding.encode(request: URLRequest(url: url), parameters: target.parameters)
        } catch {
            completionHandler(nil, NSError())
        }
        
        request.httpBody = target.body
        request.httpMethod = target.method.rawValue
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 15.0
        
        request.setValue("application/json", forHTTPHeaderField: MercadoPagoService.HeaderField.contentType.rawValue)
        if let sdkVersion = MercadoPagoBundle.bundleShortVersionString() {
            let value = "PX/iOS/" + sdkVersion
            request.setValue(value, forHTTPHeaderField: MercadoPagoService.HeaderField.userAgent.rawValue)
        }

        // Add session id
        request.setValue(MPXTracker.sharedInstance.getRequestId(), forHTTPHeaderField: MercadoPagoService.HeaderField.requestId.rawValue)
        request.setValue(MPXTracker.sharedInstance.getSessionID(), forHTTPHeaderField: MercadoPagoService.HeaderField.sessionId.rawValue)

        // Language
        request.setValue(Localizator.sharedInstance.getLanguage(), forHTTPHeaderField: MercadoPagoService.HeaderField.language.rawValue)

        //Density Header
        request.setValue("xxxhdpi", forHTTPHeaderField: MercadoPagoService.HeaderField.density.rawValue)

        //Product ID Header
        if target.headers?[MercadoPagoService.HeaderField.productId.rawValue] == nil {
            request.setValue(MP_DEFAULT_PRODUCT_ID, forHTTPHeaderField: MercadoPagoService.HeaderField.productId.rawValue)
        }

        // Add platform
        request.setValue(MLBusinessAppDataService().getAppIdentifier().rawValue, forHTTPHeaderField: MercadoPagoService.HeaderField.platform.rawValue)
        
        // Add flow id
        request.setValue(MPXTracker.sharedInstance.getFlowName() ?? "unknown", forHTTPHeaderField: MercadoPagoService.HeaderField.flowId.rawValue)

        if let headers = target.headers {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        URLSession.shared.dataTask(with: request) { data, resp, error in
            if let error = error {
                completionHandler(nil, error)
            }
            
            guard let data = data else {
                completionHandler(nil, NSError())
                return
            }
            
            completionHandler(data, nil)

        }.resume()
    }
}

extension Data {
    //MARK: - Support method, to debug requests
    func mapToJSON() throws -> Any {
        do {
            return try JSONSerialization.jsonObject(with: self, options: [])
        } catch {
            fatalError()
        }
    }
}
