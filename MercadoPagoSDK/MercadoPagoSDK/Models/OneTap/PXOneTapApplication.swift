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

public struct PXApplicationStatus: Codable {
    var enabled: Bool
    var mainMessage: PXText?
    var secondaryMessage: PXText?
    var detail: String

    public enum CodingKeys: String, CodingKey {
        case enabled = "enabled"
        case mainMessage = "main_message"
        case secondaryMessage = "secondary_message"
        case detail = "detail"
    }
}

public struct PXOneTapApplication: Codable {
    var paymentMethod: PXApplicationPaymentMethod
    var validationPrograms: [PXApplicationValidationProgram]
    var status: PXApplicationStatus

    public enum CodingKeys: String, CodingKey {
        case paymentMethod = "payment_method"
        case validationPrograms = "validation_programs"
        case status = "status"
    }
}
