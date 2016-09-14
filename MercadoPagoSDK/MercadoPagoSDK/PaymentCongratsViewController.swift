//
//  PaymentCongratsViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoTracker

public class PaymentCongratsViewController: MercadoPagoUIViewController , MPPaymentTrackInformer, UITableViewDelegate, UITableViewDataSource {

    let congratsLayout =
        ["approved" : ["header" : "approvedPaymentHeader", "body" : "approvedPaymentBody", "headerColor" : UIColor(red: 210, green: 229, blue: 202), "screenName" : "CONGRATS"],
        "rejected" : ["header" : "rejectedPaymentHeader", "body" : "rejectedPaymentBody", "headerColor" : UIColor(red: 248, green: 218, blue: 218), "screenName" : "REJECTION"],
        "recovery" : ["header" : "rejectedPaymentHeader", "body" : "recoveryPaymentBody", "headerColor" : UIColor(red: 248, green: 218, blue: 218), "screenName" : "REJECTION"],
        "authorize" : ["header" : "authorizePaymentHeader", "body" : "authorizePaymentBody", "headerColor" : UIColor(red: 190, green: 230, blue: 245), "screenName" : "CALL_FOR_AUTHORIZE"],
        "in_process" : ["header" : "pendingPaymentHeader", "body" : "", "headerColor" : UIColor(red: 245, green: 241, blue: 211), "screenName" : "PENDING"]
        ]
    override public var screenName : String { get { return self.getScreenName() } }
    var bundle = MercadoPago.getBundle()
    var payment : Payment!
    var paymentMethod : PaymentMethod!
    var layoutTemplate : String!
    var callback : ((payment : Payment, status : MPStepBuilder.CongratsState) -> Void)!
    
    
    
    @IBOutlet weak var congratsContentTable: UITableView!

    init(payment: Payment, paymentMethod : PaymentMethod, callback : (payment : Payment, status : MPStepBuilder.CongratsState) -> Void){
        super.init(nibName: "PaymentCongratsViewController", bundle : bundle)
        self.payment = payment
        self.callback = callback
        self.paymentMethod = paymentMethod
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadMPStyles(){
        
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.registerCells()
        self.layoutTemplate = getLayoutName(self.payment)
        
        self.congratsContentTable.delegate = self
        self.congratsContentTable.dataSource = self
        
        self.congratsContentTable.tableHeaderView = UIView(frame: CGRectMake(0.0, 0.0,
            self.congratsContentTable.bounds.size.width, 0.01))
        self.congratsContentTable.rowHeight = UITableViewAutomaticDimension
        self.congratsContentTable.estimatedRowHeight = 160.0
        }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil

        if self.navigationController != nil && self.navigationController?.navigationBar != nil {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            ViewUtils.addStatusBar(self.view, color: self.congratsLayout[self.layoutTemplate]!["headerColor"] as! UIColor)
        }

    }

    override public func  viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
         MPTracker.trackPaymentEvent(payment.tokenId, mpDelegate: MercadoPagoContext.sharedInstance, paymentInformer: self, flavor: Flavor(rawValue: "3"), action: "CREATE_PAYMENT", result:nil)
    }
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let header = congratsLayout[self.layoutTemplate]!["header"] as! String
            let headerCell =  self.congratsContentTable.dequeueReusableCellWithIdentifier(header) as! CongratsFillmentDelegate
            return headerCell.fillCell(self.payment, paymentMethod : self.paymentMethod, callback: nil)
        } else if indexPath.section == 1 {
            let body = congratsLayout[self.layoutTemplate]!["body"] as? String
            if body != nil && body?.characters.count > 0 {
                let bodyCell = self.congratsContentTable.dequeueReusableCellWithIdentifier(body!) as! CongratsFillmentDelegate
                let callback = self.congratsCallback()
                 var cell = bodyCell.fillCell(self.payment, paymentMethod : self.paymentMethod, callback: callback)
                if (body == "authorizePaymentBody"){
                    (cell as! AuthorizePaymentBodyTableViewCell).authCallback = {
                            let status = MPStepBuilder.CongratsState.CALL_FOR_AUTH
                            MPTracker.trackEvent(MercadoPagoContext.sharedInstance, screen: self.getScreenName(), action: "RECOVER_TOKEN", result: nil)
                            self.invokeCallback(status)
                        
                    }
                }
                return cell
            }
            return UITableViewCell()
        }
        
        let exitButtonCell = self.congratsContentTable.dequeueReusableCellWithIdentifier("exitButtonCell") as! ExitButtonTableViewCell
        exitButtonCell.exitButton.setAttributedTitle(NSAttributedString(string: "Seguir comprando".localized), forState: .Normal)
        exitButtonCell.userInteractionEnabled = true
        exitButtonCell.defaultCallback = {
            if self.navigationController != nil && self.navigationController?.navigationBar != nil {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
            }
            self.invokeCallback(MPStepBuilder.CongratsState.OK)
            
        }
        return exitButtonCell
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
   
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let layoutTemplate = self.congratsLayout[self.layoutTemplate]
        switch indexPath.section {
            case 0 :
                let header = layoutTemplate!["header"] as! String
                let cell = self.congratsContentTable.dequeueReusableCellWithIdentifier(header) as! CongratsFillmentDelegate
                return cell.getCellHeight(self.payment, paymentMethod: self.paymentMethod)
            case 1:
                let body = layoutTemplate!["body"] as! String
                if body.characters.count > 0 {
                    let cell = self.congratsContentTable.dequeueReusableCellWithIdentifier(body) as! CongratsFillmentDelegate
                    
                    return cell.getCellHeight(self.payment, paymentMethod: self.paymentMethod)
                }
                // No body found
                return 0
            default :
                return 44
            }
    }

    
    public func methodId() -> String!{
        return payment!.paymentMethodId
    }
    public func status() -> String!{
        return payment!.status
    }
    public func statusDetail() -> String!{
        return payment!.statusDetail
    }
    public func typeId() -> String!{
        return payment!.paymentTypeId
    }
    public func installments() -> String!{
        return String(payment!.installments)
    }
    public func issuerId() -> String!{
        return String(payment!.issuerId)
    }
    
    
    
    
    private func registerCells(){
        let approvedPaymentHeader = UINib(nibName: "ApprovedPaymentHeaderTableViewCell", bundle: self.bundle)
        self.congratsContentTable.registerNib(approvedPaymentHeader, forCellReuseIdentifier: "approvedPaymentHeader")
        let approvedPaymentBody = UINib(nibName: "ApprovedPaymentBodyTableViewCell", bundle: self.bundle)
        self.congratsContentTable.registerNib(approvedPaymentBody, forCellReuseIdentifier: "approvedPaymentBody")
        
        let rejectedPaymentHeader = UINib(nibName: "RejectedPaymentHeaderTableViewCell", bundle: self.bundle)
        self.congratsContentTable.registerNib(rejectedPaymentHeader, forCellReuseIdentifier: "rejectedPaymentHeader")
        let rejectedPaymentBody = UINib(nibName: "RejectedPaymentBodyTableViewCell", bundle: self.bundle)
        self.congratsContentTable.registerNib(rejectedPaymentBody, forCellReuseIdentifier: "rejectedPaymentBody")
        

        let recoveryPaymentBody = UINib(nibName: "RecoverPaymentBodyTableViewCell", bundle: self.bundle)
        self.congratsContentTable.registerNib(recoveryPaymentBody, forCellReuseIdentifier: "recoveryPaymentBody")
        
        
        let authorizePaymentHeader = UINib(nibName: "AuthorizePaymentHeaderTableViewCell", bundle: self.bundle)
        self.congratsContentTable.registerNib(authorizePaymentHeader, forCellReuseIdentifier: "authorizePaymentHeader")
        let authorizePaymentBody = UINib(nibName: "AuthorizePaymentBodyTableViewCell", bundle: self.bundle)
        self.congratsContentTable.registerNib(authorizePaymentBody, forCellReuseIdentifier: "authorizePaymentBody")
        
        let pendingPaymentHeader = UINib(nibName: "PendingPaymentHeaderTableViewCell", bundle: self.bundle)
        self.congratsContentTable.registerNib(pendingPaymentHeader, forCellReuseIdentifier: "pendingPaymentHeader")
        
        let exitButtonCell = UINib(nibName: "ExitButtonTableViewCell", bundle: self.bundle)
        self.congratsContentTable.registerNib(exitButtonCell, forCellReuseIdentifier: "exitButtonCell")
        
    }
    
    internal func getLayoutName(payment : Payment) -> String! {
    
        if payment.status == PaymentStatus.REJECTED.rawValue {
            if payment.statusDetail != nil && payment.statusDetail == "cc_rejected_call_for_authorize" {
                return "authorize" //C4A
            }else if payment.statusDetail != nil && payment.statusDetail.containsString("cc_rejected_bad_filled")  {
                 return "recovery" //bad fill something
            }
        }
        
        return payment.status
    }
    
    

    private func getScreenName() -> String {
        let layoutName = self.getLayoutName(self.payment)
        let t = self.congratsLayout[layoutName] as! NSDictionary
        return t["screenName"] as! String
    }
    
    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    internal func invokeCallback(status : MPStepBuilder.CongratsState){
        self.callback(payment: self.payment, status: status)
    }
    
    func congratsCallback() -> (Void -> Void){
        return {
            var status = MPStepBuilder.CongratsState.OK
            if self.payment.status == PaymentStatus.REJECTED.rawValue {
                if self.payment.statusDetail == "cc_rejected_call_for_authorize" {
                    MPTracker.trackEvent(MercadoPagoContext.sharedInstance, screen: self.getScreenName(), action: "SELECT_OTHER_PAYMENT_METHOD", result: nil)
                    status = MPStepBuilder.CongratsState.CANCEL_SELECT_OTHER
                }else if self.payment.statusDetail != nil && self.payment.statusDetail.containsString("cc_rejected_bad_filled"){
                    MPTracker.trackEvent(MercadoPagoContext.sharedInstance, screen: self.getScreenName(), action: "RECOVER_PAYMENT", result: nil)
                    status = MPStepBuilder.CongratsState.CANCEL_RECOVER
                }else {
                     MPTracker.trackEvent(MercadoPagoContext.sharedInstance, screen: self.getScreenName(), action: "SELECT_OTHER_PAYMENT_METHOD", result: nil)
                    status = MPStepBuilder.CongratsState.CANCEL_SELECT_OTHER
                }
            }
            self.invokeCallback(status)
        }
    }
    
    private func validPayment() -> Bool {
        return self.payment != nil && self.payment.statusDetail != nil && self.payment.statusDetail.isNotEmpty && self.paymentMethod != nil && self.paymentMethod._id != nil && self.paymentMethod._id.isNotEmpty && self.paymentMethod.name != nil && self.paymentMethod.name.isNotEmpty && self.paymentMethod.paymentTypeId != nil && self.paymentMethod.paymentTypeId.isNotEmpty
        
    }

}

enum PaymentStatus : String {
    case APPROVED = "approved"
    case REJECTED = "rejected"
    case RECOVERY = "recovery"
    case IN_PROCESS = "in_process"
}
