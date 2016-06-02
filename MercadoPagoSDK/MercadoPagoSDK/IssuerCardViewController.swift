//
//  IssuerCardViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 5/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class IssuerCardViewController: MercadoPagoUIViewController {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var bundle : NSBundle? = MercadoPago.getBundle()
    var callback : (( issuer: Issuer) -> Void)?
    
    var cardToken : CardToken?
    var paymentMethod : PaymentMethod?
    var issuerList : [Issuer]?
    var cardFront : CardFrontView?
    var fontColor = UIColor(netHex:0x333333)

    
    public init(paymentMethod: PaymentMethod,  cardToken: CardToken , issuerList: [Issuer]? = nil, callback : (( issuer: Issuer) -> Void)) {
        
        super.init(nibName: "IssuerCardViewController", bundle: MercadoPago.getBundle())
        
        self.edgesForExtendedLayout = UIRectEdge.None
        self.cardToken = cardToken
        self.callback = callback
        self.paymentMethod = paymentMethod
        self.issuerList = issuerList
        
    }
    
    override func loadMPStyles(){
        
        if self.navigationController != nil {
            
            
            //Navigation bar colors
            let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 18)!]
            
            if self.navigationController != nil {
                self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
                self.navigationItem.hidesBackButton = true
                self.navigationController!.interactivePopGestureRecognizer?.delegate = self
                self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
                self.navigationController?.navigationBar.barTintColor = UIColor(red: 90, green: 190, blue: 231)
                self.navigationController?.navigationBar.removeBottomLine()
                self.navigationController?.navigationBar.translucent = false
                //Create navigation buttons
                displayBackButton()
            }
        }
        
    }

    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cardView.addSubview(cardFront!)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
         tableView.tableFooterView = UIView()
        let issuerNib = UINib(nibName: "IssuerTableViewCell", bundle: self.bundle)
        self.tableView.registerNib(issuerNib, forCellReuseIdentifier: "issuerCell")
        cardFront = CardFrontView(frame: self.cardView.bounds)
        cardFront?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.updateCardSkin()
        // Do any additional setup after loading the view.
    }
    
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.leftBarButtonItem!.action = Selector("invokeCallbackCancel")
        
        self.showLoading()
        if(issuerList == nil){
            MPServicesBuilder.getIssuers(self.paymentMethod!, bin: self.cardToken!.getBin(), success: { (issuers) -> Void in
                self.issuerList = issuers
                self.tableView.reloadData()
                self.hideLoading()
            }) { (error) -> Void in
                // HANDLE ERROR
            }
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
        
        if(self.issuerList == nil){
            return 0
        }else{
            return (issuerList?.count)!
        }
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let issuerCell : IssuerTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("issuerCell") as! IssuerTableViewCell
        
        let issuer : Issuer = issuerList![indexPath.row]
        issuerCell.fillWithIssuer(issuer)
        return issuerCell
    }

    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        callback!(issuer: self.issuerList![indexPath.row])
    }
    public func updateCardSkin() {
        
        if(self.paymentMethod != nil){
            
            self.cardFront?.cardLogo.image =  MercadoPago.getImageFor(self.paymentMethod!)
            self.cardView.backgroundColor = MercadoPago.getColorFor(self.paymentMethod!)
            self.cardFront?.cardLogo.alpha = 1
             self.fontColor = MercadoPago.getFontColorFor(self.paymentMethod!)!
            
            cardFront?.cardNumber.text = "xxxx xxxx xxxx " + String(((self.cardToken?.cardNumber)! as String).characters.suffix(4))
            
            cardFront?.cardName.text = self.cardToken?.cardholder!.name
            cardFront?.cardExpirationDate.text = self.cardToken?.getExpirationDateFormated() as? String
            
           
            cardFront?.cardNumber.textColor =  fontColor
            cardFront?.cardName.textColor =  fontColor
            cardFront?.cardExpirationDate.textColor =  fontColor
            
        }
        
    }

}
