//
//  FlowTrackInfo.swift
//  MPTracker
//
//  Created by Demian Tejo on 5/10/16.
//  Copyright © 2016 Demian Tejo. All rights reserved.
//

import Foundation

open class FlowTrackInfo: NSObject {
    
    static let FLOW_FLAVOR : UInt = 1
    static let FLOW_TYPE : UInt = 2
    static let FLOW_FRAMEWORK : UInt = 3
    static let FLOW_SDK_VERSION : UInt = 4
    static let FLOW_PUBLIC_KEY : UInt = 5
 
    var flavor : Flavor!
    var type : String!
    var framework : String!
    var sdkVersion : String!
    var publicKey : String!
    
    static let kIsFlowSdkHybrid = "flow_sdk_type_hybrid"
    
    init(flavor : Flavor!, framework : String!, sdkVersion : String!, publicKey : String!){
        
        self.flavor = flavor
        self.type = FlowTrackInfo.getSdkType()
        self.framework = framework
        self.sdkVersion = sdkVersion
        self.publicKey = publicKey
        
    }
    
    open static func getSdkType() -> String {
        let isHybridFlowType : Bool = Utils.getSetting(identifier: FlowTrackInfo.kIsFlowSdkHybrid)
        if isHybridFlowType {
            return "hybrid"
        }
        return "native"
    }
    
    
}
