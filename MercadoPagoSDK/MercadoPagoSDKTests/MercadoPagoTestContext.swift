//
//  MercadoPagoTestContext.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 18/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
import XCTest

public class MercadoPagoTestContext : NSObject {
    
    static let sharedInstance = MercadoPagoTestContext()
    var expectations = ExpectationHash()
    var testEnvironment : XCTestCase?
    
    private override init() {
        
    }
    
    class func hasExpectations() -> Bool {
        return self.sharedInstance.expectations.count() > 0
    }
    
   /* class func addExpectation(expectation : XCTestExpectation){
        self.sharedInstance.expectations.add(expectation)
    }
    
    class func addExpectation(withDescription expectationDescription : String) {
        let expectation = self.sharedInstance.testEnvironment!.expectation(description: expectationDescription)
        self.sharedInstance.expectations.add(expectation)
    }
    
    class func fulfillExpectation(withKey : String) {
        if self.sharedInstance.expectations.count() > 0 {
            self.sharedInstance.expectations.fulfillExpectation(withKey)
        }
    }*/

    
}

struct ExpectationHash {
    var items = [String : XCTestExpectation]()
    mutating func add(expectation: XCTestExpectation) {
        items[expectation.description] = expectation
    }
    
    mutating func remove(withKey : String) {
        items.removeValue(forKey: withKey)
    }
    
    mutating func count() -> Int {
        return items.count
    }
    
    mutating func show() {
        print(items)
    }
    
    mutating func fulfillExpectation(withKey : String) {
        if let expectation = items[withKey] {
           expectation.fulfill()
          // self.remove(withKey)
        }
    }
}
