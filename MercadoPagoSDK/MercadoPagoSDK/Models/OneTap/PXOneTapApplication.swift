//
//  PXOneTapApplication.swift
//  MercadoPagoSDKV4
//
//  Created by Jonathan Scaramal on 16/03/2021.
//
public struct PXApplicationPaymentMethod: Codable {
    var id: String?
    var type: String?
}

public struct PXApplicationValidationProgram: Codable {
    var id: String
    var mandatory: Bool
}

public struct PXOneTapApplication: Codable {
    var paymentMethod: PXApplicationPaymentMethod
    var validationPrograms: [PXApplicationValidationProgram]
    var status: PXStatus

    public enum CodingKeys: String, CodingKey {
        case paymentMethod = "payment_method"
        case validationPrograms = "validation_programs"
        case status = "status"
    }
}
