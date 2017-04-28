//
//  MPTrackerDelegate.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 10/18/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

public protocol MPTrackerDelegate  {
    
    func flavor() -> Flavor!
    func framework() -> String!
    func sdkVersion() -> String!
    func publicKey() -> String!
    func siteId() -> String!
    
}

