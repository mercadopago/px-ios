//
//  DiscountServices.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 12/26/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit


open class DiscountService: MercadoPagoService {
    open let MP_DISCOUNT_CAMPAING =  "/discount_campaigns/"
    
    public override init(){
        super.init(baseURL: ServicePreference.MP_API_BASE_URL)
    }
    
 
    open func getDiscount(amount : Double, code : String? = nil, success: @escaping (_ discount: DiscountCoupon?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        var params = "public_key=" + MercadoPagoContext.publicKey() + "&transaction_amount=" + String(amount)
        
        if let couponCode = code {
            params = params + "&coupon_code=" + String(couponCode).trimSpaces()
        }
        
        params = params + "&api_version=" + ServicePreference.API_VERSION
        
        
        
        self.request(uri: MP_DISCOUNT_CAMPAING, params: params, body: nil, method: "GET", cache: false , success: { (jsonResult) -> Void in
            
            if let discount = jsonResult as? NSDictionary {
                if let error = discount["error"] {
                    failure(NSError(domain: "mercadopago.sdk.DiscountService.getDiscount", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey : error]))
                } else {
                    let discount = DiscountCoupon.fromJSON(jsonResult as! NSDictionary, amount: amount)
                    success(discount)
                }
            }
            
        },  failure: { (error) -> Void in
            failure(NSError(domain: "mercadopago.sdk.DiscountService.getDiscount", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey : "Verifique su conexión a internet e intente nuevamente".localized]))
        })
    }

}
