//
//  MercadoPagoUIViewControllerTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class MercadoPagoUIViewControllerTest: BaseTest {
    
    let viewController = MercadoPagoUIViewController()

    override func setUp() {
        super.setUp()
        MercadoPagoTestContext.addExpectation(withDescription: "MockExpectation")
        MercadoPagoTestContext.fulfillExpectation("MockExpectation")
        self.simulateViewDidLoadFor(self.viewController)
        
    }

    func testClearMercadoPagoStyleAndGoBack(){
        self.viewController.clearMercadoPagoStyleAndGoBack()
        XCTAssertTrue(self.viewController.navigationController == nil || self.viewController.navigationController!.navigationBar.titleTextAttributes == nil)
        XCTAssertTrue(self.viewController.navigationController == nil || self.viewController.navigationController!.navigationBar.barTintColor == nil)
    }
    
    func testClearMercadoPagoStyleAndGoBackAnimated(){
        self.viewController.clearMercadoPagoStyleAndGoBackAnimated()
        XCTAssertTrue(self.viewController.navigationController == nil || self.viewController.navigationController!.navigationBar.titleTextAttributes == nil)
        XCTAssertTrue(self.viewController.navigationController == nil || self.viewController.navigationController!.navigationBar.barTintColor == nil)
    }
    
}
