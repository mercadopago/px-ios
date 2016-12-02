//
//  InstructionsViewControllerTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class InstructionsViewControllerTest: BaseTest {
    
    var instructionsViewController : InstructionsViewController?

    override func setUp() {
        super.setUp()
       // MercadoPagoContext.setPublicKey(MockBuilder.MOCK_PUBLIC_KEY)
      //  let offlinePayment = MockBuilder.buildPayment("oxxo")
       /* self.instructionsViewController = InstructionsViewController(payment: offlinePayment, callback: { (Payment) -> Void in
            
        })
        self.simulateViewDidLoadFor(self.instructionsViewController!)*/
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
  /*  func testInstructionsScreens(){
         MercadoPagoUIViewController.loadFont(MercadoPago.DEFAULT_FONT_NAME)
        
        XCTAssertEqual((instructionsViewController?.instructionsByPaymentMethod["oxxo"])!, ["body" : "simpleInstructionsCell", "body_heigth" : 130, "footer" : "defaultInstructionsFooterCell", "footer_height" : 86])
        
        XCTAssertEqual(instructionsViewController!.instructionsByPaymentMethod["serfin_ticket"]!, ["body" : "instructionsTwoLabelsCell" , "body_heigth" : 200, "footer" : "defaultInstructionsFooterCell", "footer_height" : 86])
        
        XCTAssertEqual(instructionsViewController!.instructionsByPaymentMethod["bancomer_ticket"]!, ["body" : "instructionsTwoLabelsCell" , "body_heigth" : 200, "footer" : "intructionsWithTertiaryInfoFooterCell", "footer_height" : 180])
        
        XCTAssertEqual(instructionsViewController!.instructionsByPaymentMethod["7eleven"]!,["body" : "instructionsTwoLabelsCell" , "body_heigth" : 200, "footer" : "defaultInstructionsFooterCell", "footer_height" : 86])
        
        XCTAssertEqual(instructionsViewController!.instructionsByPaymentMethod["banamex_ticket"]!,["body" : "instructionsCell" , "body_heigth" : 230, "footer" : "defaultInstructionsFooterCell", "footer_height" : 86])
        
        XCTAssertEqual(instructionsViewController!.instructionsByPaymentMethod["telecomm"]!,["body" : "instructionsCell" , "body_heigth" : 230, "footer" : "intructionsWithTertiaryInfoFooterCell", "footer_height" : 180])
        
        
        XCTAssertEqual(instructionsViewController!.instructionsByPaymentMethod["serfin_bank_transfer"]!,["body" : "simpleInstructionWithButtonViewCell" , "body_heigth" : 208, "footer" : "intructionsWithSecondaryInfoFooterCell", "footer_height" : 120])
        
        XCTAssertEqual(instructionsViewController!.instructionsByPaymentMethod["banamex_bank_transfer"]!,["body" : "instructionsWithButtonCell" , "body_heigth" : 276, "footer" : "intructionsWithSecondaryInfoFooterCell", "footer_height" : 120])
        
        XCTAssertEqual(instructionsViewController!.instructionsByPaymentMethod["bancomer_bank_transfer"]!,["body" : "instructionsTwoLabelsAndButtonViewCell" , "body_heigth" : 258, "footer" : "intructionsWithSecondaryInfoFooterCell", "footer_height" : 120])
    
    }
    
    func testViewDidLoad() {

        XCTAssertNotNil(self.instructionsViewController?.currentInstruction)
        XCTAssertNotNil(self.instructionsViewController?.congratsTable)
        
    }
    
    func testVerifyInstructionsTableConstraints(){
        XCTAssertEqual(self.instructionsViewController?.numberOfSectionsInTableView(self.instructionsViewController!.congratsTable), 4)

        XCTAssertEqual(self.instructionsViewController!.tableView(self.instructionsViewController!.congratsTable, numberOfRowsInSection: 1), 1)
        
    }
    
    func testResolveBodyHeightForRow (){
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsBodyHeightForRow("oxxo"), 130)
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsBodyHeightForRow("serfin_ticket"), 200)
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsBodyHeightForRow("bancomer_ticket"), 200)
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsBodyHeightForRow("7eleven"), 200)
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsBodyHeightForRow("banamex_ticket"),
                            230)
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsBodyHeightForRow("telecomm"), 230)
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsBodyHeightForRow("serfin_bank_transfer"), 208)
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsBodyHeightForRow("banamex_bank_transfer"), 276)
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsBodyHeightForRow("bancomer_bank_transfer"), 258)
    }
    
    func testResolveInstructionsFooterHeight (){
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsFooterHeight("oxxo"), 86)
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsFooterHeight("serfin_ticket"), 86)
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsFooterHeight("bancomer_ticket"), 180)
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsFooterHeight("7eleven"), 86)
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsFooterHeight("banamex_ticket"),
            86)
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsFooterHeight("telecomm"), 180)
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsFooterHeight("serfin_bank_transfer"), 120)
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsFooterHeight("banamex_bank_transfer"), 120)
        XCTAssertEqual(self.instructionsViewController?.resolveInstructionsFooterHeight("bancomer_bank_transfer"), 120)
    }
    
    func testFinishInstruction(){
        let expectMercadoPagoStylesAreCleared = expectationWithDescription("finishInstruction")
        self.instructionsViewController?.callback = { (Payment) -> Void in
            expectMercadoPagoStylesAreCleared.fulfill()
        }
/*        self.instructionsViewController!.finishInstructions()
        self.waitForExpectationsWithTimeout(10.0, handler: nil)*/
    }
    */
   
}
