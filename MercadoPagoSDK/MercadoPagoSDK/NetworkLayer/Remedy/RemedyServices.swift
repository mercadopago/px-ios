//
//  RemedyServices.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 05/02/21.
//

protocol RemedyServices {
    func getRemedy(privateKey: String?,
                   oneTap: Bool,
                   payerPaymentMethodRejected: PXPayerPaymentMethodRejected,
                   alternativePayerPaymentMethods: [PXRemedyPaymentMethod]?,
                   completion: @escaping (PXRemedy?, PXError?) -> Void)
}

final class RemedyServicesImpl: RemedyServices {
    // MARK: - Private properties
    private let service: Requesting<RemedyRequestInfos>
    
    // MARK: - Initialization
    init(service: Requesting<RemedyRequestInfos> = Requesting<RemedyRequestInfos>()) {
        self.service = service
    }
    
    // MARK: - Public methods
    func getRemedy(privateKey: String?, oneTap: Bool, payerPaymentMethodRejected: PXPayerPaymentMethodRejected, alternativePayerPaymentMethods: [PXRemedyPaymentMethod]?, completion: @escaping (PXRemedy?, PXError?) -> Void) {
        let remedyBody = PXRemedyBody(payerPaymentMethodRejected: payerPaymentMethodRejected, alternativePayerPaymentMethods: alternativePayerPaymentMethods)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let body = try? encoder.encode(remedyBody)
        
        service.requestObject(model: PXRemedy.self, .getRemedy(privateKey, oneTap, body)) { remedy, error in
            if let _ = error {
                completion(nil, PXError(domain: ApiDomain.GET_REMEDY,
                                        code: ErrorTypes.NO_INTERNET_ERROR,
                                        userInfo: [
                                            NSLocalizedDescriptionKey: "Hubo un error",
                                            NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"
                                        ]))
            } else {
                completion(remedy, nil)
            }
        }
    }
}
