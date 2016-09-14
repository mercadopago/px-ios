//
//  PayerCostViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 3/22/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class PayerCostViewController: MercadoPagoUIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var bundle : NSBundle? = MercadoPago.getBundle()
    var installments : [Installment]?
    var payerCosts : [PayerCost]?
    var paymentMethod : PaymentMethod?
    var token : Token?
    var amount : Double!
    var issuer : Issuer?
    var cardFront : CardFrontView?
    var maxInstallments : Int?
    var fontColor = UIColor(netHex:0x333333)
    var callback : ((payerCost: PayerCost) -> Void)?
    @IBOutlet weak var cardView: UIView!
    override public var screenName : String { get { return "CARD_INSTALLMENTS" } }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    public init(paymentMethod : PaymentMethod?,issuer : Issuer?,token : Token?,amount : Double?, paymentPreference: PaymentPreference? = nil, installment : Installment? = nil, callback : ((payerCost: PayerCost) -> Void),
                callbackCancel : (Void -> Void)? = nil) {
        super.init(nibName: "PayerCostViewController", bundle: self.bundle)
     self.edgesForExtendedLayout = UIRectEdge.None
         self.paymentMethod = paymentMethod
        self.token = token!
        self.callback = callback
        self.callbackCancel = callbackCancel
        if (paymentPreference != nil){
            self.maxInstallments = paymentPreference?.maxAcceptedInstallments
        }
       
        if(installment != nil){
            self.payerCosts = installment!.payerCosts
            self.installments = [installment!]
        }
        

        self.amount = amount
        self.issuer = issuer
        
        
 

    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem!.action = Selector("invokeCallbackCancel")
        if self.installments == nil {
            self.showLoading()
            self.getInstallments()
        } else {
            self.payerCosts = installments![0].payerCosts
        }
    }
    
    override func loadMPStyles(){
        
        if self.navigationController != nil {
            
            
            //Navigation bar colors
            let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.systemFontColor(), NSFontAttributeName: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 18)!]
            
            if self.navigationController != nil {
                self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
                self.navigationItem.hidesBackButton = true
                self.navigationController!.interactivePopGestureRecognizer?.delegate = self
                self.navigationController?.navigationBar.tintColor = UIColor.systemFontColor()
                self.navigationController?.navigationBar.barTintColor = UIColor.primaryColor()
                self.navigationController?.navigationBar.removeBottomLine()
                self.navigationController?.navigationBar.translucent = false
                //Create navigation buttons
                displayBackButton()
            }
        }
        
    }

    public func updateCardSkin() {
        
        if(self.paymentMethod != nil){
            
            self.cardFront?.cardLogo.image =  MercadoPago.getImageFor(self.paymentMethod!)
            self.cardView.backgroundColor = MercadoPago.getColorFor(self.paymentMethod!)
            self.cardFront?.cardLogo.alpha = 1
            self.fontColor = MercadoPago.getFontColorFor(self.paymentMethod!)!
            
            
            let lastFourDigits = (self.token!.lastFourDigits as String) ?? "XXXX "
            cardFront?.cardNumber.text =  "XXXX XXXX XXXX " + lastFourDigits
        
                
            if self.token?.cardHolder != nil {
                cardFront?.cardName.text = self.token!.cardHolder!.name
                
            }
            
            cardFront?.cardExpirationDate.text = self.token!.getExpirationDateFormated() as String
            cardFront?.cardNumber.alpha = 0.7
            cardFront?.cardName.alpha = 0.7
            cardFront?.cardExpirationDate.alpha = 0.7
            cardFront?.cardNumber.textColor =  fontColor
            cardFront?.cardName.textColor =  fontColor
            cardFront?.cardExpirationDate.textColor =  fontColor
        }
        
    }

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        /*
        UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:view];
        */
        self.view.backgroundColor = UIColor.complementaryColor()
        tableView.tableFooterView = UIView()
        cardFront = CardFrontView(frame: self.cardView.bounds)
        cardFront?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        let installmentNib = UINib(nibName: "InstallmentSelectionTableViewCell", bundle: self.bundle)
        self.tableView.registerNib(installmentNib, forCellReuseIdentifier: "installmentCell")
        // Do any additional setup after loading the view.
        updateCardSkin()
    
        
    }
    

    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cardView.addSubview(cardFront!)
        if(self.payerCosts == nil){
            self.getInstallments()
        }else{
            self.tableView.reloadData()
        }
        
    }
    
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
       
        return 50
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(self.payerCosts == nil){
            return 0
        }else{
            return installments![0].numberOfPayerCostToShow(maxInstallments)
        }
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let payerCost : PayerCost = payerCosts![indexPath.row]
        let installmentCell = tableView.dequeueReusableCellWithIdentifier("installmentCell", forIndexPath: indexPath) as! InstallmentSelectionTableViewCell
        installmentCell.fillCell(payerCost)
  
        
        ViewUtils.drawBottomLine(y : 50, width: self.view.bounds.width, inView: installmentCell)

        return installmentCell
    }
    
    
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let payerCost : PayerCost = payerCosts![indexPath.row]
        self.callback!(payerCost: payerCost)
    }
    
    private func getInstallments(){
        MPServicesBuilder.getInstallments((token?.getBin())!  , amount: self.amount, issuer: self.issuer, paymentMethodId: self.paymentMethod!._id, success: { (installments) -> Void in
            self.installments = installments
            self.payerCosts = installments![0].payerCosts
            //TODO ISSUER
            self.tableView.reloadData()
            self.hideLoading()
        }) { (error) -> Void in
           self.requestFailure(error)
        }

    }

    
  
}
    
    








