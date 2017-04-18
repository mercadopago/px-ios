//
//  AddCouponViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class AddCouponViewModel: NSObject {
    
    var amount : Double!
    var coupon : DiscountCoupon?
  
    let DISCOUNT_ERROR_AMOUNT_DOESNT_MATCH = "amount-doesnt-match"
    let DISCOUNT_ERROR_RUN_OUT_OF_USES = "run out of uses"
    let DISCOUNT_ERROR_CAMPAIGN_DOESNT_MATCH = "campaign-doesnt-match"
    let DISCOUNT_ERROR_CAMPAIGN_EXPIRED = "campaign-expired"
    
    init(amount : Double) {
        self.amount = amount
    }
    

    func getCoupon(code: String, success: @escaping (Void) -> Void, failure: @escaping ((_ errorMessage: String) -> Void)){
        let disco = DiscountService()

        disco.getDiscount(amount: self.amount, code: code, success: { (coupon) in
            if let coupon = coupon{
                self.coupon = coupon
                success()
            }
        }) { (error) in
            if (error.localizedDescription == self.DISCOUNT_ERROR_CAMPAIGN_DOESNT_MATCH){
                failure("Vendedor sin descuento disponible".localized)
            }else if (error.localizedDescription == self.DISCOUNT_ERROR_RUN_OUT_OF_USES){
                failure("Se agotó la cantidad de usos".localized)
            }else if (error.localizedDescription == self.DISCOUNT_ERROR_AMOUNT_DOESNT_MATCH){
                failure("Importe fuera del alcance".localized)
            }else if (error.localizedDescription == self.DISCOUNT_ERROR_CAMPAIGN_EXPIRED){
                failure("La campaña expiró".localized)
            }else {
                failure("Algo salió mal… ".localized)
            }
        }
    }
    

}
