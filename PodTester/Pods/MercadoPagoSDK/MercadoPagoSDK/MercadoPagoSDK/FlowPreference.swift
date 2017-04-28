//
//  FlowPreference.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class FlowPreference : NSObject{
    var showReviewAndConfirmScreen = true
    var showPaymentResultScreen = true
    var showPaymentApprovedScreen = true
    var showPaymentRejectedScreen = true
    var showPaymentPendingScreen = true
    var showPaymentSearchScreen = true
    
    public func disableReviewAndConfirmScreen(){
        showReviewAndConfirmScreen = false
    }
    
    public func disablePaymentResultScreen(){
        showPaymentResultScreen = false
    }
    
    public func disablePaymentApprovedScreen(){
        showPaymentApprovedScreen = false
    }
    
    public func disablePaymentRejectedScreen(){
        showPaymentRejectedScreen = false
    }
    
    public func disablePaymentPendingScreen(){
        showPaymentPendingScreen = false
    }
    
    public func disableDefaultSelection(){
        showPaymentSearchScreen = false
    }
    
    /*public func setCongratsDisplayTime(){
    
     }*/

    public func enableReviewAndConfirmScreen(){
        showReviewAndConfirmScreen = true
    }
    
    public func enablePaymentResultScreen(){
        showPaymentResultScreen = true
    }
    
    public func enablePaymentApprovedScreen(){
        showPaymentApprovedScreen = true
    }
    
    public func enablePaymentRejectedScreen(){
        showPaymentRejectedScreen = true
    }
    
    public func enablePaymentPendingScreen(){
        showPaymentPendingScreen = true
    }
    
    public func enableDefaultSelection(){
        showPaymentSearchScreen = true
    }

    
    public func isReviewAndConfirmScreenEnable() -> Bool{
        return showReviewAndConfirmScreen
    }
    
    public func isPaymentResultScreenEnable() -> Bool{
        return showPaymentResultScreen
    }
    
    public func isPaymentApprovedScreenEnable() -> Bool{
        return showPaymentApprovedScreen
    }
    
    public func isPaymentRejectedScreenEnable() -> Bool{
        return showPaymentRejectedScreen
    }
    
    public func isPaymentPendingScreenEnable() -> Bool{
        return showPaymentPendingScreen
    }
    public func isPaymentSearchScreenEnable() -> Bool{
        return showPaymentSearchScreen
    }
}
