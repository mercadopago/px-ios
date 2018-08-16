//
//  Languages.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 5/8/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

//TODO: v4 sign - Ver si lo usamos/exponemos.
@objc public enum Languages: Int {
    case _SPANISH
    case _SPANISH_MEXICO
    case _SPANISH_COLOMBIA
    case _SPANISH_URUGUAY
    case _SPANISH_PERU
    case _SPANISH_VENEZUELA
    case _PORTUGUESE
    case _ENGLISH

    func langPrefix() -> String {
        switch self {
        case ._SPANISH : return "es"
        case ._SPANISH_MEXICO : return "es-MX"
        case ._SPANISH_COLOMBIA : return "es-CO"
        case ._SPANISH_URUGUAY : return "es-UY"
        case ._SPANISH_PERU : return "es-PE"
        case ._SPANISH_VENEZUELA : return "es-VE"
        case ._PORTUGUESE : return "pt"
        case ._ENGLISH : return "en"
        }
    }
}
