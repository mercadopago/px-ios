//
//  InstructionsServices.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 06/02/21.
//

protocol InstructionsServices {
    func getInstructions(paymentId: String,
                         accessToken: String?,
                         publicKey: String,
                         completion: @escaping (PXInstructions?, PXError?) -> Void)
}

final class InstructionsServicesImpl: InstructionsServices {
    // MARK: - Private properties
    private let service: Requesting<InstructionsrequestInfos>
    
    // MARK: - Initialization
    init(service: Requesting<InstructionsrequestInfos> = Requesting<InstructionsrequestInfos>()) {
        self.service = service
    }
    
    // MARK: - Public methods
    func getInstructions(paymentId: String, accessToken: String?, publicKey: String, completion: @escaping (PXInstructions?, PXError?) -> Void) {
        service.requestObject(model: PXInstructions.self, .getInstructions(paymentId, accessToken, publicKey)) { instruction, error in
            if let _ = error {
                completion(nil, PXError(domain: ApiDomain.GET_INSTRUCTIONS, code: ErrorTypes.NO_INTERNET_ERROR,
                                        userInfo: [
                                            NSLocalizedDescriptionKey: "Hubo un error",
                                            NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"
                                        ]))
            } else {
                completion(instruction, nil)
            }
        }
    }
}


