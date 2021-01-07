//
//  CustomPaymentProcessor.swift
//  ExampleSwift
//
//  Created by Jonathan Scaramal on 20/10/2020.
//  Copyright © 2020 Juan Sebastian Sanzone. All rights reserved.
//

import UIKit

#if PX_PRIVATE_POD
    import MercadoPagoSDKV4
#else
    import MercadoPagoSDK
#endif

class CustomPaymentProcessor : NSObject, PXPaymentProcessor {
    
    var checkoutStore : PXCheckoutStore?
    
    func startPayment(checkoutStore: PXCheckoutStore, errorHandler: PXPaymentProcessorErrorHandler, successWithBusinessResult: @escaping ((PXBusinessResult) -> Void), successWithPaymentResult: @escaping ((PXGenericPayment) -> Void)) {
        print("Start payment")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
//            successWithPaymentResult(PXGenericPayment(paymentStatus: .APPROVED, statusDetail: "Pago aprobado desde procesadora custom!"))
//            successWithPaymentResult(PXGenericPayment(paymentStatus: .REJECTED, statusDetail: "Pago rechazado desde procesadora custom!"))
            successWithBusinessResult(PXBusinessResult(receiptId: "Random ID", status: .APPROVED, title: "Business title", subtitle: "Business subtitle", icon: nil, mainAction: PXAction(label: "Business action", action: { print("Action business") }), secondaryAction: nil, helpMessage: "Business help message", showPaymentMethod: true, statementDescription: "Business statement description", imageUrl: nil, topCustomView: nil, bottomCustomView: nil, paymentStatus: "Aprobado business", paymentStatusDetail: "Detalle status business", paymentMethodId: "paymentMethodId", paymentTypeId: "paymentTypeId", importantView: nil))
        })
                
    }
    
    func paymentProcessorViewController() -> UIViewController? {
        return nil
    }
    
    func support() -> Bool {
        return true
    }
    
    func didReceive(checkoutStore: PXCheckoutStore) {
        print("Receiving checkout store")
        self.checkoutStore = checkoutStore
    }
    
    func didReceive(navigationHandler: PXPaymentProcessorNavigationHandler) {
        print("Receiving navigation Handler")
    }
    
}
