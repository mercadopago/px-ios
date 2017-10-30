//
//  AddCouponViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class AddCouponViewModel: NSObject {

    var amount: Double!
    var coupon: DiscountCoupon?
    var email: String!
    var mercadoPagoServicesAdapter: MercadoPagoServicesAdapter!

    let DISCOUNT_ERROR_AMOUNT_DOESNT_MATCH = "amount-doesnt-match"
    let DISCOUNT_ERROR_RUN_OUT_OF_USES = "run out of uses"
    let DISCOUNT_ERROR_CAMPAIGN_DOESNT_MATCH = "campaign-doesnt-match"
    let DISCOUNT_ERROR_CAMPAIGN_EXPIRED = "campaign-expired"

    init(amount: Double, email: String, mercadoPagoServicesAdapter: MercadoPagoServicesAdapter) {
        self.amount = amount
        self.email = email
        self.mercadoPagoServicesAdapter = mercadoPagoServicesAdapter
    }

    func getCoupon(code: String, success: @escaping () -> Void, failure: @escaping ((_ errorMessage: String) -> Void)) {
        self.mercadoPagoServicesAdapter.getCodeDiscount(amount: self.amount, payerEmail: self.email, couponCode: code, discountAdditionalInfo: MercadoPagoCheckoutViewModel.servicePreference.discountAdditionalInfo, callback: { [weak self] (discount) in

            if let coupon = discount {
                self?.coupon = discount
                success()
            }

        }) { (error) in

            if error.localizedDescription == self.DISCOUNT_ERROR_CAMPAIGN_DOESNT_MATCH {
                failure("Vendedor sin descuento disponible".localized)
            } else if error.localizedDescription == self.DISCOUNT_ERROR_RUN_OUT_OF_USES {
                failure("Se agotó la cantidad de usos".localized)
            } else if error.localizedDescription == self.DISCOUNT_ERROR_AMOUNT_DOESNT_MATCH {
                failure("Importe fuera del alcance".localized)
            } else if error.localizedDescription == self.DISCOUNT_ERROR_CAMPAIGN_EXPIRED {
                failure("La campaña expiró".localized)
            } else {
                failure("Algo salió mal… ".localized)
            }

        }
    }
}
