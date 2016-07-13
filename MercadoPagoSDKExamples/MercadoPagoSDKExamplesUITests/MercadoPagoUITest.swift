//
//  MercadoPagoUITest.swift
//  MercadoPagoSDKExamples
//
//  Created by Demian Tejo on 7/13/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

public class MercadoPagoUITest: XCTestCase {
    
    
    static var sharedApplication =  XCUIApplication()
    static var initializedApplication = false
    var application : XCUIApplication =  MercadoPagoUITest.sharedApplication
    
    override public func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        if(!MercadoPagoUITest.initializedApplication){
            MercadoPagoUITest.initializedApplication = true
            MercadoPagoUITest.sharedApplication.launchArguments = ["UITestingEnabled"]
            MercadoPagoUITest.sharedApplication.launch()
        }
        
        //application = MercadoPagoUITest.sharedApplication
        
    }

    
    override public func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
}
