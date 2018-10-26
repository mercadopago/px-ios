//
//  PXCustomStringConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Nicolas Frugoni on 10/25/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

@objcMembers
open class PXCustomStringConfiguration: NSObject {
    
    private var mainVerb: String = "Verbo Pagar".localized
    
}

// MARK: - Internal Getters
extension PXCustomStringConfiguration {
    private func getMainVerb() -> String {
        return mainVerb;
    }
    
    internal func getTotalRowTitle() -> String {
        return "total_row_title_default".localized_beta.replacingOccurrences(of: "%1$s", with: getMainVerb())
    }
    
    internal func getPaymentMethodsScreenTitle() -> String {
        return "¿Cómo quieres pagar?".localized.replacingOccurrences(of: "%1$s", with: getMainVerb())
    }
}

// MARK: - Builder
extension PXCustomStringConfiguration {
    /**
     Add your own payment method option to pay.
     - parameter plugin: Your custom payment method plugin.
     */
    open func setMainVerb(mainVerb: String) -> PXCustomStringConfiguration {
        self.mainVerb = mainVerb
        return self
    }
}
