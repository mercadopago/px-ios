//
//  PXResultConstants.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

// MARK: Header Constants
struct PXHeaderResutlConstants {

    // Header titles
    static let APPROVED_HEADER_TITLE = "¡Listo! Se acreditó tu pago"
    static let PENDING_HEADER_TITLE = "Estamos procesando el pago"
    static let REJECTED_HEADER_TITLE = "Uy, no pudimos procesar el pago"

    // Icon subtext
    static let REJECTED_ICON_SUBTEXT = "Algo salió mal..."

}
// MARK: Footer Constants
struct PXFooterResultConstants {

    // Button texts
    static let ERROR_BUTTON_TEXT = "Pagar con otro medio"
    static let C4AUTH_BUTTON_TEXT = "Pagar con otro medio"
    static let CARD_DISABLE_BUTTON_TEXT = "Ya habilité mi tarjeta"
    static let WARNING_BUTTON_TEXT = "Revisar los datos de tarjeta"
    static let DEFAULT_BUTTON_TEXT: String? = nil

    // Link texts
    static let APPROVED_LINK_TEXT = "Seguir comprando"
    static let ERROR_LINK_TEXT = "Cancelar pago"
    static let C4AUTH_LINK_TEXT = "Cancelar pago"
    static let WARNING_LINK_TEXT = "Pagar con otro medio"
    static let DEFAULT_LINK_TEXT = "Seguir comprando"
}
