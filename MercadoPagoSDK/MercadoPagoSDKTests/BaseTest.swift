//
//  BaseCase.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 21/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class BaseTest: XCTestCase {

    static let WAIT_FOR_REQUEST_EXPECTATION_DESCRIPTION = "waitForRequest"
    static let WAIT_FOR_NAVIGATION_CONTROLLER = "waitForNavigationController"
    static let WAIT_FOR_VIEW_LOADED = "waitForViewDidLoad"
    static let WAIT_EXPECTATION_TIME_INTERVAL = 10.0

    override func setUp() {
        super.setUp()
        MercadoPagoContext.setPublicKey(MockBuilder.MLA_PK)
        MercadoPagoTestContext.sharedInstance.testEnvironment = self
    }

    override func tearDown() {
        super.tearDown()
        MercadoPagoCheckoutViewModel.clearEnviroment()
    }

    func simulateViewDidLoadFor(viewController: UIViewController) -> UIViewController {
        let nav = UINavigationController(rootViewController: viewController)
        _ = viewController.view
        viewController.viewWillAppear(false)
        viewController.viewDidAppear(false)

        waitForExpectations(timeout: BaseTest.WAIT_EXPECTATION_TIME_INTERVAL, handler: nil)

        return viewController
    }

}

extension UINavigationController {

    /*func pushViewController(viewController: UIViewController,
                            animated: Bool, completion: @escaping (@escaping Void) -> Void) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }*/

}
