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
    
    var callback : ((payerCost: PayerCost) -> Void)?
    @IBOutlet weak var cardView: UIView!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    public init(paymentMethod : PaymentMethod?,issuer : Issuer?,token : Token?,amount : Double?,maxInstallments : Int?, installment : Installment? = nil, callback : ((payerCost: PayerCost) -> Void)) {
        super.init(nibName: "PayerCostViewController", bundle: self.bundle)
     self.edgesForExtendedLayout = UIRectEdge.None
        //self.edgesForExtendedLayout = .All
         self.paymentMethod = paymentMethod
        self.token = token!
        self.callback = callback
        self.maxInstallments = maxInstallments

        if(installment != nil){
            self.payerCosts = installment!.payerCosts
            self.installments = [installment!]
        }
        

        self.amount = amount
        self.issuer = issuer
        
        
        if(self.payerCosts == nil){
            self.getInstallments()
        }else{
            self.tableView.reloadData()
        }
       

    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem!.action = Selector("invokeCallbackCancel")
        print(cardView.bounds)
        if self.installments == nil {
            self.getInstallments()
        }
    }
    
    
    public func updateCardSkin() {
        
        if(self.paymentMethod != nil){
            
            self.cardFront?.cardLogo.image =  MercadoPago.getImageFor(self.paymentMethod!)
            self.cardView.backgroundColor = MercadoPago.getColorFor(self.paymentMethod!)
            self.cardFront?.cardLogo.alpha = 1
            
            
            cardFront?.cardNumber.text = self.token!.firstSixDigit as String
        // TODO
        
            cardFront?.cardName.text = self.token!.cardHolder!.name
            cardFront?.cardExpirationDate.text = self.token!.getExpirationDateFormated() as String
            
            cardFront?.cardNumber.textColor =  defaultColorText
            cardFront?.cardName.textColor =  defaultColorText
            cardFront?.cardExpirationDate.textColor =  defaultColorText

        }
        
    }
    let defaultColorText = UIColor(netHex:0x333333)
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        /*
        UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:view];
        */
        
        cardFront = CardFrontView(frame: self.cardView.bounds)
        cardFront?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        let installmentNib = UINib(nibName: "PayerCostTableViewCell", bundle: self.bundle)
        self.tableView.registerNib(installmentNib, forCellReuseIdentifier: "PayerCostTableViewCell")
        // Do any additional setup after loading the view.
        updateCardSkin()
    
        
    }
    

    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cardView.addSubview(cardFront!)

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
        


        let installmentCell = tableView.dequeueReusableCellWithIdentifier("PayerCostTableViewCell", forIndexPath: indexPath) as! PayerCostTableViewCell
        
        
        
        let payerCost : PayerCost = payerCosts![indexPath.row]
        
        let mpLightGrayColor = UIColor(netHex: 0x999999)
        let totalAttributes: [String:AnyObject] = [NSFontAttributeName : UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 16)!,NSForegroundColorAttributeName:mpLightGrayColor]
        let totalAmountStr = NSMutableAttributedString(string:" ( ", attributes: totalAttributes)
        
        let totalAmount = Utils.getAttributedAmount(String(payerCost.totalAmount), thousandSeparator: ",", decimalSeparator: ".", currencySymbol: "$" , color:mpLightGrayColor)
        totalAmountStr.appendAttributedString(totalAmount)
        totalAmountStr.appendAttributedString(NSMutableAttributedString(string:" ) ", attributes: totalAttributes))
        
        let additionalText = payerCost.installmentRate > 0 || payerCost.installments == 1 ? "" : " Sin interes".localized
        if additionalText.characters.count > 0 {
            let additionalTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 67, green: 176,blue: 0), NSFontAttributeName : UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: 13)!]
            totalAmountStr.appendAttributedString(NSAttributedString(string: additionalText, attributes: additionalTextAttributes))
        }
        
        
        installmentCell.payerCostDetail.attributedText =  Utils.getTransactionInstallmentsDescription(payerCost.installments.description, installmentAmount: payerCost.installmentAmount, additionalString: totalAmountStr)
        
        
            //= payerCosts![indexPath.row].recommendedMessage
        return installmentCell
    }
    
    
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let payerCost : PayerCost = payerCosts![indexPath.row]
        self.callback!(payerCost: payerCost)
    }
    
    private func getInstallments(){
        MPServicesBuilder.getInstallments((token?.getBin())!  , amount: self.amount, issuer: self.issuer, paymentTypeId: PaymentTypeId.CREDIT_CARD, success: { (installments) -> Void in
            self.installments = installments
            self.payerCosts = installments![0].payerCosts
            //TODO ISSUER
            
            self.tableView.reloadData()
        }) { (error) -> Void in
           self.requestFailure(error)
        }

    }

    
  
}
    
    








