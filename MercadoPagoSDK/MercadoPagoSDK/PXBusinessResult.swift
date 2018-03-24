//
//  PXBusinessResult.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 8/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

@objc public enum PXBusinessResultStatus: Int {
    case APPROVED
    case REJECTED
    case PENDING
    case IN_PROGRESS
    
    func getDescription() -> String {
        switch self {
        case .APPROVED : return "APPROVED"
        case .REJECTED  : return "REJECTED"
        case .PENDING   : return "PENDING"
        case .IN_PROGRESS : return "IN PROGRESS"
        }
    }
}

/*
 Esta clase representa un resultado de pago de negocio.
 Por ejemplo, cuando hay un error al momento de realizar un pago que tiene que ver con el negocio y no con el payment method.
 */
open class PXBusinessResult: NSObject {

    var status: PXBusinessResultStatus // APPROVED REJECTED PENDING
    var title: String // Titluo de Congrats
    var subtitle: String? // Sub Titluo de Congrats
    var icon: UIImage  // Icono de Congrats
    var mainAction: PXComponentAction? // Boton principal (Azul)
    var secondaryAction: PXComponentAction // Boton secundario (link) - Obligatoria
    var helpMessage: String? // Texto
    /* De momento es inaccesible */private var showPaymentMethod: Bool = false // Si quiere que muestre la celda de PM
    
    //Datos que actualmente devuelve la procesadora de pagos
    var receiptId: String? = nil
    //------
    
    public init(receiptId: String? = nil, status: PXBusinessResultStatus, title: String, subtitle: String? = nil, icon: UIImage, mainAction: PXComponentAction? = nil, secondaryAction: PXComponentAction, helpMessage: String? = nil /*, showPaymentMethod : Bool = false*/ ) { // De momento no dejamos configurar el showPaymentMethod
        self.receiptId = receiptId
        self.status = status
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.mainAction = mainAction
        self.secondaryAction = secondaryAction
        self.helpMessage = helpMessage
        super.init()
    }    
}
