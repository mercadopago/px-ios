//
//  MPTracker.swift
//  MPTracker
//
//  Created by Demian Tejo on 5/9/16.
//  Copyright © 2016 Demian Tejo. All rights reserved.
//

import Foundation

public enum Flavor : String {
    case Flavor_1 = "1"
    case Flavor_2 = "2"
    case Flavor_3 = "3"
}



/*
public enum GAKey : String {
    case MLA = "UA-46085787-6"
    case MLB = "UA-46090222-6"
    case MLM = "UA-46090517-10"
    case MLC = "UA-46085697-7"
    case MCO = "UA-46087162-10"
    case MLV = "UA-46090035-10"
    
    
    static func parseToGAKey(_ gakeyString : String) -> GAKey{
        switch gakeyString {
        case "MLA":
            return GAKey.MLA
        case "MLB":
            return GAKey.MLB
        case "MLM":
            return GAKey.MLM
        case "MLC":
            return GAKey.MLC
        case "MCO":
            return GAKey.MCO
        case "MLV":
            return GAKey.MLV
        default:
            return GAKey.MLA
        }
    }
}
*/
@objc
public protocol MPTrackListener   {
    func trackScreen(screenName : String)
    func trackEvent(screenName : String?, action: String!, result: String?, extraParams: [String:String]?)
}
@objc
public protocol MPPaymentTrackInformer {

    
    func methodId() -> String!
    func status() -> String!
    func statusDetail() -> String!
    func typeId() -> String!
    func installments() -> String!
    func issuerId() -> String!
    
    
}
open class MPTracker : NSObject {


    static var initialized : Bool = false

   // static var siteGAKey : GAKey?
    
    static var flavor : Flavor? = nil

    static let kGenericScreenName = "NO_SCREEN_DEFINED"
    
    fileprivate class func initialize (_ mpDelegate : MPTrackerDelegate!){
        MPTracker.initialized = true
   //     siteGAKey = GAKey.parseToGAKey(mpDelegate.siteId())
   //     GATracker.sharedInstance.initialized(flowTrackInfo(mpDelegate), gaKey: siteGAKey)
        MPTracker.flavor = mpDelegate.flavor()
    }
    
    open class func trackEvent(_ mpDelegate: MPTrackerDelegate!, screen: String! = kGenericScreenName, action: String!, result: String?){
        if (!initialized){
            self.initialize(mpDelegate)
        }
        if let listener = MercadoPagoContext.getTrackListener() {
            listener.trackEvent(screenName: screen, action: action, result: result, extraParams: nil)
        }
    //    GATracker.sharedInstance.trackEvent(flavorText() + "/" + screen, action:action , label:result)
    }
    
    
    open class func trackPaymentEvent(_ token: String!, mpDelegate: MPTrackerDelegate!, paymentInformer: MPPaymentTrackInformer, flavor: Flavor!, screen: String! = "NO_SCREEN", action: String!, result: String?){
        if (!initialized){
            self.initialize(mpDelegate)
        }
        if let listener = MercadoPagoContext.getTrackListener() {
            listener.trackEvent(screenName: screen, action: action, result: result, extraParams: nil)
        }
    //    GATracker.sharedInstance.trackPaymentEvent(flavorText() + "/" + screen, action: action, label: result, paymentInformer: paymentInformer)
       // PaymentTracker.trackToken(token, delegate: mpDelegate)
    }
    
    open class func trackPaymentOffEvent(_ paymentId: String!, mpDelegate: MPTrackerDelegate){
        if (!initialized){
            self.initialize(mpDelegate)
        }
        MPTracker.trackEvent(mpDelegate, action: "", result: "")
        PaymentTracker.trackPaymentOff(paymentId: paymentId, delegate: mpDelegate)
    }
    
    
    fileprivate class func flowTrackInfo(_ mpDelegate: MPTrackerDelegate!) -> FlowTrackInfo {
    
        let flowInfo : FlowTrackInfo = FlowTrackInfo(flavor: mpDelegate.flavor(), framework: mpDelegate.framework(), sdkVersion: mpDelegate.sdkVersion(), publicKey: mpDelegate.publicKey())
        
        return flowInfo
    }
    
    open class func trackScreenName(_ mpDelegate : MPTrackerDelegate!, screenName: String!){
        
        if String.isNullOrEmpty(screenName) || screenName == MPTracker.kGenericScreenName {
            // Don't track invalid screen names
            return
        }
        
        if (!initialized){
            self.initialize(mpDelegate)
        }
        if let listener = MercadoPagoContext.getTrackListener() {
            listener.trackScreen(screenName: screenName)
        }
   //     GATracker.sharedInstance.trackScreen(flavorText() + "/" + screenName)
    }
    
    open class func trackCreateToken(_ mpDelegate: MPTrackerDelegate!,token: String!){
        PaymentTracker.trackToken(token: token, delegate: mpDelegate)
    }
    
    fileprivate class func flavorText() -> String{
        
        if (MPTracker.flavor != nil){
            return "F" + (MPTracker.flavor?.rawValue)!
        }else{
            return ""
        }
        
    }

}
