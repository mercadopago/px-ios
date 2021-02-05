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
    //MARK: - Public methods
    func requestObject<Model>(model: Model.Type, _ target: Target, completionHandler: @escaping (Model?, Error?) -> Void) where Model : Codable {
        guard let url = URL(string: "\(target.baseURL)\(target.endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            completionHandler(nil, NSError())
            return
        }
        
        var request = URLRequest(url: url)
    
        do {
            request = try target.parameterEncoding.encode(request: URLRequest(url: url), parameters: target.parameters)
        } catch {
            completionHandler(nil, NSError())
        }
        
        request.httpBody = target.body
        
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
        guard let url = URL(string: "\(target.baseURL)\(target.endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            completionHandler(nil, NSError())
            return
        }
        
        var request = URLRequest(url: url)
        
        do {
            request = try target.parameterEncoding.encode(request: URLRequest(url: url), parameters: target.parameters)
        } catch {
            completionHandler(nil, NSError())
        }
        
        request.httpBody = target.body
        
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
        guard let url = URL(string: "\(target.baseURL)\(target.endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            completionHandler(nil, NSError())
            return
        }
        
        var request = URLRequest(url: url)
        
        do {
            request = try target.parameterEncoding.encode(request: URLRequest(url: url), parameters: target.parameters)
        } catch {
            completionHandler(nil, NSError())
        }
        
        request.httpBody = target.body
        
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
