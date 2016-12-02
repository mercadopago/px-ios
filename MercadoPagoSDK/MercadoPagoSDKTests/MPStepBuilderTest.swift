//
//  MPStepBuilderTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 8/29/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
import XCTest
@testable import MercadoPagoSDK

class MPStepBuilderTest: BaseTest {

//    func testStartPaymentResultStep_approvedCCPayment() {
//        let mockPayment = MockBuilder.buildPayment("visa")
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
//        let finalVC = MPStepBuilder.startPaymentResultStep(mockPayment, paymentMethod: paymentMethod) { (payment, status) in
//            
//        }
//        XCTAssertNotNil(finalVC)
//        XCTAssertTrue(finalVC.isKindOfClass(PaymentCongratsViewController))
//        let paymentCongratsVC = finalVC as! PaymentCongratsViewController
//        XCTAssertEqual(paymentCongratsVC.status(), "approved")
//        
//        let layout = paymentCongratsVC.getLayoutName(mockPayment)
//        XCTAssertEqual(layout, "approved")
//    }
//    
//    func testStartPaymentResultStep_rejectedCCPayment() {
//        let mockPayment = MockBuilder.buildPayment("visa", status: "rejected")
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
//        let finalVC = MPStepBuilder.startPaymentResultStep(mockPayment, paymentMethod: paymentMethod) { (payment, status) in
//            
//        }
//        XCTAssertNotNil(finalVC)
//        XCTAssertTrue(finalVC.isKindOfClass(PaymentCongratsViewController))
//        let paymentCongratsVC = finalVC as! PaymentCongratsViewController
//        XCTAssertEqual(paymentCongratsVC.status(), "rejected")
//        
//        let layout = paymentCongratsVC.getLayoutName(mockPayment)
//        XCTAssertEqual(layout, "rejected")
//    }
//    
//    func testStartPaymentResultStep_callForAuthorizeCCPayment() {
//        let mockPayment = MockBuilder.buildPayment("visa", status: "rejected", statusDetail : "cc_rejected_call_for_authorize")
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
//        let finalVC = MPStepBuilder.startPaymentResultStep(mockPayment, paymentMethod: paymentMethod) { (payment, status) in
//            
//        }
//        XCTAssertNotNil(finalVC)
//        XCTAssertTrue(finalVC.isKindOfClass(PaymentCongratsViewController))
//        let paymentCongratsVC = finalVC as! PaymentCongratsViewController
//        XCTAssertEqual(paymentCongratsVC.status(), "rejected")
//        
//        let layout = paymentCongratsVC.getLayoutName(mockPayment)
//        XCTAssertEqual(layout, "authorize")
//    }
//    
//    func testStartPaymentResultStep_pendingCCPayment() {
//        let mockPayment = MockBuilder.buildPayment("visa", status: "pending")
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
//        let finalVC = MPStepBuilder.startPaymentResultStep(mockPayment, paymentMethod: paymentMethod) { (payment, status) in
//            
//        }
//        XCTAssertNotNil(finalVC)
//        XCTAssertTrue(finalVC.isKindOfClass(PaymentCongratsViewController))
//        let paymentCongratsVC = finalVC as! PaymentCongratsViewController
//        XCTAssertEqual(paymentCongratsVC.status(), "pending")
//        
//        let layout = paymentCongratsVC.getLayoutName(mockPayment)
//        XCTAssertEqual(layout, "pending")
//    }
//    
//    func testStartPaymentResultStep_instructionsMLA() {
//        let mockPayment = MockBuilder.buildOffPayment("rapipago")
//        let paymentMethod = MockBuilder.buildPaymentMethod("rapipago")
//        let finalVC = MPStepBuilder.startPaymentResultStep(mockPayment, paymentMethod: paymentMethod) { (payment, status) in
//            
//        }
//        XCTAssertNotNil(finalVC)
//        XCTAssertTrue(finalVC.isKindOfClass(PaymentCongratsViewController))
//        let paymentCongratsVC = finalVC as! PaymentCongratsViewController
//        XCTAssertEqual(paymentCongratsVC.status(), "pending")
//        
//        let layout = paymentCongratsVC.getLayoutName(mockPayment)
//        XCTAssertEqual(layout, "pending")
//    }
}
