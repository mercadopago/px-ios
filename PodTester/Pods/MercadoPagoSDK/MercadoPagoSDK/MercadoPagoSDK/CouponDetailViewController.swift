//
//  CouponDetailViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 12/23/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class CouponDetailViewController: MercadoPagoUIViewController {
    
    let cuponViewWidth : CGFloat = 256.0
    let cuponViewHeight : CGFloat = 200.0
    override open var screenName : String { get { return "DISCOUNT_SUMMARY" } }
    var couponView : DiscountDetailView!
    var viewModel : CouponDetailViewModel!
    
    init(coupon : DiscountCoupon, callbackCancel : ((Void) -> Void)? = nil) {
        super.init(nibName: "CouponDetailViewController", bundle: MercadoPago.getBundle())
        self.callbackCancel = callbackCancel
        self.viewModel = CouponDetailViewModel(coupon: coupon)
    }
    
    init(viewModel: CouponDetailViewModel, callbackCancel : ((Void) -> Void)? = nil) {
        super.init(nibName: "CouponDetailViewController", bundle: MercadoPago.getBundle())
        self.callbackCancel = callbackCancel
        self.viewModel = viewModel
    }
    

    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        let screenSize: CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height
        let screenWidth = screenSize.width
        let xPos = (screenWidth - cuponViewWidth)/2
        let yPos = (screenHeight - cuponViewHeight)/2
        self.couponView = DiscountDetailView(frame:CGRect(x: xPos, y: yPos, width:cuponViewWidth , height: cuponViewHeight), coupon: self.viewModel.coupon, amount:self.viewModel.coupon.amount)
        self.couponView.layer.cornerRadius = 4
        self.couponView.layer.masksToBounds = true
        self.view.addSubview(self.couponView)
    }
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func exit(){
        guard let callbackCancel = self.callbackCancel else {
            self.dismiss(animated: false, completion: nil)
            return
        }
        self.dismiss(animated: false) { 
            callbackCancel()
        }
        
    }
    
}


class CouponDetailViewModel : NSObject {
    var coupon : DiscountCoupon!
    init(coupon : DiscountCoupon) {
        self.coupon = coupon
    }
    
}
