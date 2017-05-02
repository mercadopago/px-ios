//
//  MPErrorException.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 20/4/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

public enum MPErrorException: Error {
    case invalidPaymentMethod
    case invalidInputData(message : String)
}
