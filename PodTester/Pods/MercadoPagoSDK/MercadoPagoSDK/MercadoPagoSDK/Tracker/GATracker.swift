 //
//  GATracker.swift
//  MPTracker
//
//  Created by Demian Tejo on 5/9/16.
//  Copyright © 2016 Demian Tejo. All rights reserved.
//
/*
import UIKit

open class GATracker: NSObject {

    static let sharedInstance = GATracker()
       static var gainitialized : Bool = false

    
    internal func initialized(_ flowInfo : FlowTrackInfo!, gaKey : GAKey!){
        
        if (!GATracker.gainitialized){
            let gai = GAI.sharedInstance()
            gai!.tracker(withTrackingId: gaKey.rawValue)
            gai!.trackUncaughtExceptions = true
            GATracker.gainitialized = true
            let tracker = GAI.sharedInstance().defaultTracker
            tracker?.set(GAIFields.customDimension(for: FlowTrackInfo.FLOW_FLAVOR), value: String(flowInfo.flavor.rawValue))
            tracker?.set(GAIFields.customDimension(for: FlowTrackInfo.FLOW_FRAMEWORK), value: flowInfo.framework)
            tracker?.set(GAIFields.customDimension(for: FlowTrackInfo.FLOW_PUBLIC_KEY), value: flowInfo.publicKey)
            tracker?.set(GAIFields.customDimension(for: FlowTrackInfo.FLOW_SDK_VERSION), value: flowInfo.sdkVersion)
        }
        


    }
    
    internal func trackScreen(_ screenName : String){
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: screenName)
    
        let builder = GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject]
        
        tracker?.send(builder)
    }
    
    
    internal func trackPaymentEvent(_ category: String!, action: String!, label: String!, value: NSNumber = 0, paymentInformer : MPPaymentTrackInformer){
        let tracker = GAI.sharedInstance().defaultTracker
        
        let eventTracker = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value)
        eventTracker?.set(paymentInformer.installments(), forKey: GAIFields.customDimension(for: PaymentTrackInfo.PAYMENT_INSTALLMENTS))
        eventTracker?.set(paymentInformer.issuerId(), forKey: GAIFields.customDimension(for: PaymentTrackInfo.PAYMENT_ISSUER_ID))
        eventTracker?.set(paymentInformer.methodId(), forKey: GAIFields.customDimension(for: PaymentTrackInfo.PAYMENT_METHOD_ID))
        eventTracker?.set(paymentInformer.status(), forKey: GAIFields.customDimension(for: PaymentTrackInfo.PAYMENT_STATUS))
        eventTracker?.set(paymentInformer.statusDetail(), forKey: GAIFields.customDimension(for: PaymentTrackInfo.PAYMENT_STATUS_DETAIL))
        eventTracker?.set(paymentInformer.typeId(), forKey: GAIFields.customDimension(for: PaymentTrackInfo.PAYMENT_TYPE_ID))

        tracker?.send(eventTracker as! [NSObject : AnyObject])
    }
    
    internal func trackEvent(_ category: String!, action: String!, label: String!, value: NSNumber = 0){
        let tracker = GAI.sharedInstance().defaultTracker
        
        let builder = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value)
        
		tracker?.send(builder as! [NSObject : AnyObject])
    }
}
  */
