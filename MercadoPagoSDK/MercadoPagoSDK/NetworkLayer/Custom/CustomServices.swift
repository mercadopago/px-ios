//
//  CustomServices.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 08/02/21.
//

protocol CustomServices {
    func getPointsAndDiscounts(data: Data?, parameters: CustomParametersModel, response: @escaping (PXPointsAndDiscounts?, Void?) -> Void)
    func resetESCCap(cardId:String, privateKey: String?, response: @escaping (Void?, PXError?) -> Void)
    func createPayment(privateKey: String?, publicKey: String, data: Data?, header: [String : String]?, response: @escaping (PXPayment?, PXError?) -> Void)
}

final class CustomServicesImpl: CustomServices {
    // MARK: - private properties
    private let service: Requesting<CustomRequestInfos>
    
    // MARK: - Initialization
    init(service: Requesting<CustomRequestInfos> = Requesting<CustomRequestInfos>()) {
        self.service = service
    }
    
    // MARK: - Public methods
    func getPointsAndDiscounts(data: Data?, parameters: CustomParametersModel, response: @escaping (PXPointsAndDiscounts?, Void?) -> Void) {
        service.requestObject(model: PXPointsAndDiscounts.self, .getCongrats(data: data, congratsModel: parameters)) { model, error in
            if let _ = error {
                response(nil, ())
            } else {
                response(model, nil)
            }
        }
    }
    
    func resetESCCap(cardId:String, privateKey: String?, response: @escaping (Void?, PXError?) -> Void) {
        guard let privateKey = privateKey else {
            response(nil, PXError(domain: ApiDomain.RESET_ESC_CAP, code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: ["message": "Missing key"]))
            return
        }
        service.requestData(target: .resetESCCap(cardId: cardId, privateKey: privateKey)) { _, error in
            if let error = error {
                response(nil, PXError(domain: ApiDomain.RESET_ESC_CAP, code: ErrorTypes.NO_INTERNET_ERROR, userInfo: ["message": error.localizedDescription]))
            } else {
                response((), nil)
            }
        }
    }
    
    func createPayment(privateKey: String?, publicKey: String, data: Data?, header: [String : String]?, response: @escaping (PXPayment?, PXError?) -> Void) {
        service.requestObject(model: PXPayment.self, .createPayment(privateKey: privateKey, publicKey: publicKey, data: data, header: header)) { payment, error in
            if let _ = error {
                response(nil, PXError(domain: ApiDomain.CREATE_PAYMENT, code: ErrorTypes.API_UNKNOWN_ERROR, userInfo: ["message": "PAYMENT_ERROR"]))
            } else {
                response(payment, nil)
            }
        }
    }
}
