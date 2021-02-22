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
        
        service.requestData(target: .getRemedy(privateKey, oneTap, body)) { [weak self] data, error in
            guard let data = data else { return }
            self?.buildRemedy(data: data, error: error, completion: { remedy, error in
                completion(remedy, error)
            })
        }
    }
    
    // MARK: - Private Methods
    private func buildRemedy(data: Data?, error: Error?, completion: @escaping (PXRemedy?, PXError?) -> Void) {
        if let data = data {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let responseObject = try? decoder.decode(PXRemedy.self, from: data)
            completion(responseObject, nil)
        } else if let error = error {
            completion(nil, PXError(domain: ApiDomain.GET_REMEDY,
                                    code: ErrorTypes.NO_INTERNET_ERROR,
                                    userInfo: [
                                        NSLocalizedDescriptionKey: "Hubo un error",
                                        NSLocalizedFailureReasonErrorKey: error.localizedDescription
                                    ]))
        }
    }
}
