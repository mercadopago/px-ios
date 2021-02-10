//
//  GatewayServices.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 06/02/21.
//

protocol GatewayServices {
    func getToken(accessToken: String?,
                  publicKey: String,
                  cardTokenJSON: Data?,
                  completion: @escaping (PXToken?, PXError?) -> Void)
    
    func cloneToken(tokeniD: String, publicKey: String, securityCode: String, completion: @escaping (PXToken?, PXError?) -> Void)
    func validateToken(tokenId: String, publicKey: String, body: Data, completion: @escaping (PXToken?, PXError?) -> Void)
}

final class GatewayServicesImpl: GatewayServices {
    // MARK: - Private properties
    private let service: Requesting<GatewayRequestInfos>
    
    // MARK: - Initialization
    init(service: Requesting<GatewayRequestInfos> = Requesting<GatewayRequestInfos>()) {
        self.service = service
    }
    
    // MARK: - Public methods
    func getToken(accessToken: String?, publicKey: String, cardTokenJSON: Data?, completion: @escaping (PXToken?, PXError?) -> Void) {
        service.requestObject(model: PXToken.self, .getToken(accessToken, publicKey, cardTokenJSON)) { token, error in
            if let _ = error {
                completion(nil, PXError(domain: ApiDomain.GET_TOKEN,
                                        code: ErrorTypes.NO_INTERNET_ERROR,
                                        userInfo: [
                                            NSLocalizedDescriptionKey: "Hubo un error",
                                            NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"])
                )
            } else {
                completion(token, nil)
            }
        }
    }
    
    func cloneToken(tokeniD: String, publicKey: String, securityCode: String, completion: @escaping (PXToken?, PXError?) -> Void) {
        service.requestData(target: .cloneToken(tokeniD, publicKey)) { [weak self] data, error in
            if let data = data, let token = try? JSONDecoder().decode(PXToken.self , from: data) {
                let secCodeDic : [String: Any] = ["security_code": securityCode]
                guard let jsonData = try? JSONSerialization.data(withJSONObject: secCodeDic, options: .prettyPrinted) else {
                    completion(nil, PXError(domain: ApiDomain.CLONE_TOKEN,
                                            code: ErrorTypes.NO_INTERNET_ERROR,
                                            userInfo: [
                                                NSLocalizedDescriptionKey: "Hubo un error",
                                                NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"])
                    )
                    return
                }
                
                self?.validateToken(tokenId: token.id, publicKey: publicKey, body: jsonData) { data, error in
                    if let error = error {
                        completion(nil, error)
                    } else {
                        completion(data, nil)
                    }
                }
            }
        }
    }
    
    func validateToken(tokenId: String, publicKey: String, body: Data, completion: @escaping (PXToken?, PXError?) -> Void) {
        service.requestObject(model: PXToken.self, .validateToken(tokenId, publicKey, body)) { token, error in
            if let _ = error {
                completion(nil, PXError(domain: ApiDomain.CLONE_TOKEN,
                                        code: ErrorTypes.NO_INTERNET_ERROR,
                                        userInfo: [
                                            NSLocalizedDescriptionKey: "Hubo un error",
                                            NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"])
                )
            } else {
                completion(token, nil)
            }
        }
    }
}

