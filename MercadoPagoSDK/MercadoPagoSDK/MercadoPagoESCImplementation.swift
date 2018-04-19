//
//  MercadoPagoESCImplementation.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 7/21/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

#if MPESC_ENABLE
    import MLESCManager
#endif

@objcMembers
open class MercadoPagoESCImplementation: NSObject, MercadoPagoESC {

    public func hasESCEnable() -> Bool {
        #if MPESC_ENABLE
            return MercadoPagoCheckoutViewModel.flowPreference.isESCEnable()
         #else
            return false
         #endif
    }

    public func getESC(cardId: String) -> String? {
        if hasESCEnable() {
            #if MPESC_ENABLE
                let esc = ESCManager.getESC(cardId: cardId)
                return String.isNullOrEmpty(esc) ? nil : esc
            #endif
        }
        return nil
    }

    public func saveESC(cardId: String, esc: String) -> Bool {
        if hasESCEnable() {
            #if MPESC_ENABLE
               return ESCManager.saveESC(cardId: cardId, esc: esc)
            #endif
        }
        return false
    }

    public func deleteESC(cardId: String) {
        if hasESCEnable() {
            #if MPESC_ENABLE
                ESCManager.deleteESC(cardId: cardId)
            #endif
        }
    }

    public func deleteAllESC() {
        if hasESCEnable() {
            #if MPESC_ENABLE
                ESCManager.deleteAllESC()
            #endif
        }
    }
}
