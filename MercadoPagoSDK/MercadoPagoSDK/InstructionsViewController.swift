//
//  CongratsWithInstructionsViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 16/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
import Foundation

public class InstructionsViewController: MercadoPagoUIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var congratsTable: UITableView!
    
    var currentInstruction : Instruction?
    
    // NSDictionary used to build instructions screens by paymentMethodId
    let instructionsByPaymentMethod = [
        "oxxo_ticket" : ["body" : "simpleInstructionsCell", "footer" : "defaultInstructionsFooterCell", "footer_height" : 86],
        "serfin_ticket" : ["body" : "instructionsTwoLabelsCell" , "footer" : "defaultInstructionsFooterCell", "footer_height" : 86],
        "bancomer_ticket" : ["body" : "instructionsTwoLabelsCell" , "footer" : "intructionsWithTertiaryInfoFooterCell", "footer_height" : 180],
        "7eleven_ticket" : ["body" : "instructionsTwoLabelsCell" , "footer" : "defaultInstructionsFooterCell", "footer_height" : 86],
        "banamex_ticket" : ["body" : "instructionsCell" , "footer" : "defaultInstructionsFooterCell", "footer_height" : 86],
        "telecomm_ticket" : ["body" : "instructionsCell", "footer" : "intructionsWithTertiaryInfoFooterCell", "footer_height" : 180],
        "serfin_bank_transfer" : ["body" : "simpleInstructionWithButtonViewCell", "footer" : "intructionsWithSecondaryInfoFooterCell", "footer_height" : 120],
        "banamex_bank_transfer" : ["body" : "instructionsWithButtonCell", "footer" : "intructionsWithSecondaryInfoFooterCell", "footer_height" : 120],
        "bancomer_bank_transfer" : ["body" : "instructionsTwoLabelsAndButtonViewCell", "footer" : "intructionsWithSecondaryInfoFooterCell", "footer_height" : 120],
        "pagofacil_ticket" : ["body" : "simpleInstructionsCell", "footer" : "defaultInstructionsFooterCell", "footer_height" : 86],
        "rapipago_ticket" : ["body" : "simpleInstructionsCell", "footer" : "defaultInstructionsFooterCell", "footer_height" : 86],
        "bapropagos_ticket" : ["body" : "simpleInstructionsCell", "footer" : "defaultInstructionsFooterCell", "footer_height" : 86],
        "cargavirtual_ticket" : ["body" : "simpleInstructionsCell", "footer" : "defaultInstructionsFooterCell", "footer_height" : 86],
        "redlink_atm" : ["body" : "instructionsAtmCell", "footer" : "defaultInstructionsFooterCell", "footer_height" : 86],
        "redlink_bank_transfer" : ["body" : "instructionsTwoLabelsCell" , "footer" : "defaultInstructionsFooterCell", "footer_height" : 86]
        
    ]
    
    var payment : Payment!
    var paymentTypeId : PaymentTypeId!
    var callback : ((Payment) -> Void)!
    var bundle = MercadoPago.getBundle()
    
    
    public init(payment : Payment, paymentTypeId : PaymentTypeId, callback : (Payment) -> Void) {
        super.init(nibName: "InstructionsViewController", bundle: bundle)
        self.payment = payment
        self.callback = callback
        self.paymentTypeId = paymentTypeId
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.congratsTable.tableHeaderView = UIView(frame: CGRectMake(0.0, 0.0, self.congratsTable.bounds.size.width, 0.01))
        
        if self.navigationController != nil {
            self.navigationController!.interactivePopGestureRecognizer?.delegate = nil
            self.navigationController!.setNavigationBarHidden(true, animated: true)
        }
        
        ViewUtils.addStatusBar(self.view, color: UIColor(red: 245, green: 241, blue: 211))

    }
    
    override public func viewDidAppear(animated : Bool) {
        super.viewDidAppear(animated)
        self.showLoading()
        if currentInstruction == nil {
            registerAllCells()
            getInstructions()
        } else {
            self.congratsTable.reloadData()
        }
    }
    
    override public func viewWillAppear(animated: Bool) {
        self.loadMPStyles()
        self.navigationController?.navigationBar.barTintColor = UIColor().UIColorFromRGB(0xFBF8E3)
    }
    
    override public func viewWillDisappear(animated: Bool) {
        self.clearMercadoPagoStyle()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  section == 1 ? 20 : 0.01
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let instructionsHeaderCell = self.congratsTable.dequeueReusableCellWithIdentifier("instructionsHeaderCell") as! InstructionsHeaderViewCell
            return instructionsHeaderCell.fillCell(self.currentInstruction!.title, amount : self.payment.transactionAmount, currency: CurrenciesUtil.getCurrencyFor(self.payment.currencyId))
        }
        
        let instructionsSelected = self.payment.paymentMethodId.lowercaseString + "_" + self.paymentTypeId.rawValue.lowercaseString
        if indexPath.section == 1 {
            let bodyViewCell = self.resolveInstructionsBodyViewCell(instructionsSelected)!
            return bodyViewCell
        }
        
        if indexPath.section == 2 {
            let footer = self.resolveInstructionsFooter(instructionsSelected)!
            return footer
        }
        
        let exitButtonCell =  self.congratsTable.dequeueReusableCellWithIdentifier("exitButtonCell") as! ExitButtonTableViewCell
        let attributes: [String:AnyObject] = [NSFontAttributeName : UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: 14)!,NSForegroundColorAttributeName: UIColor().UIColorFromRGB(0x0066CC)]
        let title = NSAttributedString(string: "Seguir comprando".localized, attributes: attributes)
        exitButtonCell.exitButton.setAttributedTitle(title, forState: .Normal)
        exitButtonCell.defaultCallback = { self.finishInstructions() }
        
        let separatorLineView = UIView(frame: CGRect(x: 0, y: 139, width: self.view.bounds.size.width, height: 1))
        separatorLineView.layer.zPosition = 1
        separatorLineView.backgroundColor = UIColor().grayTableSeparator()
        exitButtonCell.addSubview(separatorLineView)
        exitButtonCell.bringSubviewToFront(separatorLineView)
        return exitButtonCell
    }
    
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let instructionsSelected = self.payment.paymentMethodId.lowercaseString + "_" + self.paymentTypeId.rawValue.lowercaseString
        if indexPath.section == 0 {
            let instructionsHeaderCell = self.congratsTable.dequeueReusableCellWithIdentifier("instructionsHeaderCell") as! InstructionsHeaderViewCell
            
            return instructionsHeaderCell.getCellHeight(self.currentInstruction!.title)
        }
        if indexPath.section == 1  {
            return self.resolveInstructionsBodyHeightForRow(instructionsSelected)
        } else if indexPath.section == 2 {
            return self.resolveInstructionsFooterHeight(instructionsSelected) + 20
        }
        return 44
    }

    

    internal func resolveInstructionsBodyViewCell(instructionsId : String) -> UITableViewCell? {
        let instructionScreenStructure = self.instructionsByPaymentMethod[instructionsId]
        let instructionBodyCell = instructionScreenStructure!["body"] as! String
        let cell = self.congratsTable.dequeueReusableCellWithIdentifier(instructionBodyCell) as! InstructionsFillmentDelegate
        return cell.fillCell(self.currentInstruction!)
    }
    
    internal func resolveInstructionsBodyHeightForRow(instructionsId : String) -> CGFloat {
        let instructionsLayout = self.instructionsByPaymentMethod[instructionsId]!["body"] as! String
        let cell = self.congratsTable.dequeueReusableCellWithIdentifier(instructionsLayout) as! InstructionsFillmentDelegate
        return cell.getCellHeight(self.currentInstruction!, forFontSize: 22)
    }
    
    internal func resolveInstructionsFooter(instructionsId : String) -> UITableViewCell? {
        let instructionScreenStructure = self.instructionsByPaymentMethod[instructionsId]
        let instructionFooterCell = instructionScreenStructure!["footer"] as! String
        let cell = self.congratsTable.dequeueReusableCellWithIdentifier(instructionFooterCell)  as! InstructionsFillmentDelegate
        return cell.fillCell(self.currentInstruction!)
    }
    
    internal func resolveInstructionsFooterHeight(instructionsId : String) -> CGFloat {
        let instructionScreenStructure = self.instructionsByPaymentMethod[instructionsId]
        let instructionBodyHeight = instructionScreenStructure!["footer_height"] as! CGFloat
        return instructionBodyHeight
    }
    
    internal func finishInstructions(){
        self.clearMercadoPagoStyle()
        self.callback(self.payment)
    }
    
    internal func registerAllCells() {

        // Create cell nibs
        let instructionsHeaderCell = UINib(nibName: "InstructionsHeaderViewCell", bundle: self.bundle)
        
        let instructionsCell = UINib(nibName: "InstructionsViewCell", bundle: self.bundle)
        let instructionsTwoLabelsCell = UINib(nibName: "InstructionsTwoLabelsViewCell", bundle: self.bundle)
        let simpleInstructionsViewCell = UINib(nibName: "SimpleInstructionsViewCell", bundle: self.bundle)
        let simpleInstructionsWithButtonViewCell = UINib(nibName: "SimpleInstructionsWithButtonViewCell", bundle: self.bundle)
        let instructionsWithButtonCell = UINib(nibName: "InstructionsWithButtonViewCell", bundle: self.bundle)
        let instructionsTwoLabelsWithButtonCell = UINib(nibName: "InstructionsTwoLabelsAndButtonViewCell", bundle: self.bundle)
        let instructionsAtmCell = UINib(nibName: "InstructionsAtmViewCell", bundle: self.bundle)
        
        let defaultInstructionsFooterCell = UINib(nibName: "DefaultInstructionsFooterViewCell", bundle: self.bundle)
        let instructionFooterWithTertiaryInfoCell = UINib(nibName: "InstructionsFooterWithTertiaryInfoViewCell", bundle: self.bundle)
        let instructionFooterWithSecondaryInfoCell = UINib(nibName: "InstructionsFooterWithSecondaryInfoViewCell", bundle: self.bundle)
        let exitButtonCell = UINib(nibName: "ExitButtonTableViewCell", bundle: self.bundle)
        
        // Register cell nibs in table
        self.congratsTable.registerNib(instructionsHeaderCell, forCellReuseIdentifier: "instructionsHeaderCell")
        self.congratsTable.registerNib(instructionsCell, forCellReuseIdentifier: "instructionsCell")
        self.congratsTable.registerNib(instructionsTwoLabelsCell, forCellReuseIdentifier: "instructionsTwoLabelsCell")
        self.congratsTable.registerNib(simpleInstructionsViewCell, forCellReuseIdentifier: "simpleInstructionsCell")

        self.congratsTable.registerNib(simpleInstructionsWithButtonViewCell, forCellReuseIdentifier: "simpleInstructionWithButtonViewCell")
        self.congratsTable.registerNib(instructionsWithButtonCell, forCellReuseIdentifier: "instructionsWithButtonCell")
        self.congratsTable.registerNib(instructionsTwoLabelsWithButtonCell, forCellReuseIdentifier: "instructionsTwoLabelsAndButtonViewCell")
        
        self.congratsTable.registerNib(defaultInstructionsFooterCell, forCellReuseIdentifier: "defaultInstructionsFooterCell")
        self.congratsTable.registerNib(instructionFooterWithTertiaryInfoCell, forCellReuseIdentifier: "intructionsWithTertiaryInfoFooterCell")
        self.congratsTable.registerNib(instructionFooterWithSecondaryInfoCell, forCellReuseIdentifier: "intructionsWithSecondaryInfoFooterCell")
        self.congratsTable.registerNib(exitButtonCell, forCellReuseIdentifier: "exitButtonCell")
        self.congratsTable.registerNib(instructionsAtmCell, forCellReuseIdentifier: "instructionsAtmCell")
    }
    
    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    private func getInstructions(){
        MPServicesBuilder.getInstructions(payment._id, paymentMethodId: self.payment.paymentMethodId, paymentTypeId : self.paymentTypeId.rawValue.lowercaseString, success: { (instruction) -> Void in
            self.currentInstruction = instruction
            self.congratsTable.delegate = self
            self.congratsTable.dataSource = self
            self.congratsTable.reloadData()
            self.hideLoading()
            }, failure: { (error) -> Void in
                self.requestFailure(error)
                self.hideLoading()
        })
    }
}
