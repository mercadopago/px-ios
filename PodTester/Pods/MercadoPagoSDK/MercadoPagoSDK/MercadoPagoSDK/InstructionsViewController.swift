//
//  CongratsWithInstructionsViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 16/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
import Foundation

open class InstructionsViewController: MercadoPagoUIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var congratsTable: UITableView!
    
    var currentInstruction : Instruction?
    var amountInfo : AmountInfo?
    override open var screenName : String { get { return "INSTRUCTIONS" } }
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
    
    
    public init(payment : Payment, paymentTypeId : PaymentTypeId, callback : @escaping (Payment) -> Void) {
        super.init(nibName: "InstructionsViewController", bundle: bundle)
        self.payment = payment
        self.callback = callback
        self.paymentTypeId = paymentTypeId
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.congratsTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.congratsTable.bounds.size.width, height: 0.01))
        
        if self.navigationController != nil {
            self.navigationController!.interactivePopGestureRecognizer?.delegate = nil
            self.navigationController!.setNavigationBarHidden(true, animated: true)
        }
        
        ViewUtils.addStatusBar(self.view, color: UIColor(red: 245, green: 241, blue: 211))

    }
    
    override open func viewDidAppear(_ animated : Bool) {
        super.viewDidAppear(animated)
        self.showLoading()
        if currentInstruction == nil {
            registerAllCells()
            getInstructions()
        } else {
            self.congratsTable.reloadData()
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        self.loadMPStyles()
        self.navigationController?.navigationBar.barTintColor = UIColor.primaryColor()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        self.clearMercadoPagoStyle()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> Float {
        return  section == 1 ? 20 : 0.01
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> Float {
        return 0.01
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).section == 0 {
            let instructionsHeaderCell = self.congratsTable.dequeueReusableCell(withIdentifier: "instructionsHeaderCell") as! InstructionsHeaderViewCell
            return instructionsHeaderCell.fillCell(self.currentInstruction!.title, amount : self.amountInfo!.amount!, currency: self.amountInfo!.currency!)
        }
        
        let instructionsSelected = self.payment.paymentMethodId.lowercased() + "_" + self.paymentTypeId.rawValue.lowercased()
        if (indexPath as NSIndexPath).section == 1 {
            let bodyViewCell = self.resolveInstructionsBodyViewCell(instructionsSelected)!
            return bodyViewCell
        }
        
        if (indexPath as NSIndexPath).section == 2 {
            let footer = self.resolveInstructionsFooter(instructionsSelected)!
            return footer
        }
        

        let exitButtonCell =  self.congratsTable.dequeueReusableCell(withIdentifier: "exitButtonCell") as! ExitButtonTableViewCell
        let attributes: [String:AnyObject] = [NSFontAttributeName : UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: 14) ?? UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName: UIColor.UIColorFromRGB(0x0066CC)]

        let title = NSAttributedString(string: "Seguir comprando".localized, attributes: attributes)
        exitButtonCell.exitButton.setAttributedTitle(title, for: UIControlState())
        exitButtonCell.defaultCallback = { self.finishInstructions() }
        
        let separatorLineView = UIView(frame: CGRect(x: 0, y: 139, width: self.view.bounds.size.width, height: 1))
        separatorLineView.layer.zPosition = 1
        separatorLineView.backgroundColor = UIColor.grayTableSeparator()
        exitButtonCell.addSubview(separatorLineView)
        exitButtonCell.bringSubview(toFront: separatorLineView)
        return exitButtonCell
    }
    
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> Float {
        let instructionsSelected = self.payment.paymentMethodId.lowercased() + "_" + self.paymentTypeId.rawValue.lowercased()
        if (indexPath as NSIndexPath).section == 0 {
            let instructionsHeaderCell = self.congratsTable.dequeueReusableCell(withIdentifier: "instructionsHeaderCell") as! InstructionsHeaderViewCell
            
            return instructionsHeaderCell.getCellHeight(self.currentInstruction!.title)
        }
        if (indexPath as NSIndexPath).section == 1  {
            return self.resolveInstructionsBodyHeightForRow(instructionsSelected)
        } else if (indexPath as NSIndexPath).section == 2 {
            return self.resolveInstructionsFooterHeight(instructionsSelected) + 20
        }
        return 44
    }

    

    internal func resolveInstructionsBodyViewCell(_ instructionsId : String) -> UITableViewCell? {
        let instructionScreenStructure = self.instructionsByPaymentMethod[instructionsId]
        let instructionBodyCell = instructionScreenStructure!["body"] as! String
        let cell = self.congratsTable.dequeueReusableCell(withIdentifier: instructionBodyCell) as! InstructionsFillmentDelegate
        return cell.fillCell(self.currentInstruction!)
    }
    
    internal func resolveInstructionsBodyHeightForRow(_ instructionsId : String) -> Float {
        let instructionsLayout = self.instructionsByPaymentMethod[instructionsId]!["body"] as! String
        let cell = self.congratsTable.dequeueReusableCell(withIdentifier: instructionsLayout) as! InstructionsFillmentDelegate
        return Float(cell.getCellHeight(self.currentInstruction!, forFontSize: 22))
    }
    
    internal func resolveInstructionsFooter(_ instructionsId : String) -> UITableViewCell? {
        let instructionScreenStructure = self.instructionsByPaymentMethod[instructionsId]
        let instructionFooterCell = instructionScreenStructure!["footer"] as! String
        let cell = self.congratsTable.dequeueReusableCell(withIdentifier: instructionFooterCell)  as! InstructionsFillmentDelegate
        return cell.fillCell(self.currentInstruction!)
    }
    
    internal func resolveInstructionsFooterHeight(_ instructionsId : String) -> Float {
        let instructionScreenStructure = self.instructionsByPaymentMethod[instructionsId]
        let instructionBodyHeight = instructionScreenStructure!["footer_height"] as! Float
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
        self.congratsTable.register(instructionsHeaderCell, forCellReuseIdentifier: "instructionsHeaderCell")
        self.congratsTable.register(instructionsCell, forCellReuseIdentifier: "instructionsCell")
        self.congratsTable.register(instructionsTwoLabelsCell, forCellReuseIdentifier: "instructionsTwoLabelsCell")
        self.congratsTable.register(simpleInstructionsViewCell, forCellReuseIdentifier: "simpleInstructionsCell")

        self.congratsTable.register(simpleInstructionsWithButtonViewCell, forCellReuseIdentifier: "simpleInstructionWithButtonViewCell")
        self.congratsTable.register(instructionsWithButtonCell, forCellReuseIdentifier: "instructionsWithButtonCell")
        self.congratsTable.register(instructionsTwoLabelsWithButtonCell, forCellReuseIdentifier: "instructionsTwoLabelsAndButtonViewCell")
        
        self.congratsTable.register(defaultInstructionsFooterCell, forCellReuseIdentifier: "defaultInstructionsFooterCell")
        self.congratsTable.register(instructionFooterWithTertiaryInfoCell, forCellReuseIdentifier: "intructionsWithTertiaryInfoFooterCell")
        self.congratsTable.register(instructionFooterWithSecondaryInfoCell, forCellReuseIdentifier: "intructionsWithSecondaryInfoFooterCell")
        self.congratsTable.register(exitButtonCell, forCellReuseIdentifier: "exitButtonCell")
        self.congratsTable.register(instructionsAtmCell, forCellReuseIdentifier: "instructionsAtmCell")
    }
    
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    fileprivate func getInstructions(){
        MPServicesBuilder.getInstructions(payment._id, paymentTypeId : self.paymentTypeId!.rawValue.lowercased(), success: { (instructionsInfo : InstructionsInfo) -> Void in
            self.currentInstruction = instructionsInfo.instructions[0]
            self.amountInfo = instructionsInfo.amountInfo
            self.congratsTable.delegate = self
            self.congratsTable.dataSource = self
            self.congratsTable.reloadData()
            self.hideLoading()
            }, failure: { (error) -> Void in
                self.requestFailure(error, callback: {
                    self.getInstructions()
                    }, callbackCancel: {
                        self.dismiss(animated: true, completion: {})
                })
                self.hideLoading()
        })
    }
}
