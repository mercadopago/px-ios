//
//  PayerCostViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 3/22/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class PayerCostViewController: MercadoPagoUIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var bundle : Bundle? = MercadoPago.getBundle()
    var installments : [Installment]?
    var payerCosts : [PayerCost]?
    var paymentMethod : PaymentMethod?
    var token : Token?
    var amount : Double!
    var issuer : Issuer?
    var cardFront : CardFrontView?
    var maxInstallments : Int?
    var fontColor = UIColor(netHex:0x333333)
    var callback : ((_ payerCost: PayerCost) -> Void)?
    @IBOutlet weak var cardView: UIView!
    override open var screenName : String { get { return "CARD_INSTALLMENTS" } }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    public init(paymentMethod : PaymentMethod?,issuer : Issuer?,token : Token?, amount : Double?, paymentPreference: PaymentPreference? = nil, installment : Installment? = nil,
                callback : @escaping ((_ payerCost: PayerCost) -> Void),
                callbackCancel : ((Void) -> Void)? = nil) {
        super.init(nibName: "PayerCostViewController", bundle: self.bundle)
        self.edgesForExtendedLayout = UIRectEdge()
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
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    open override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.navigationItem.leftBarButtonItem!.action = #selector(invokeCallbackCancel)
        if self.installments == nil {
            self.showLoading()
            self.getInstallments()
        } else {
            self.payerCosts = installments![0].payerCosts
        }
    }
    
    override func loadMPStyles(){
        
        if self.navigationController != nil {
            
            var titleDict: NSDictionary = [:]
            //Navigation bar colors
            if let font = UIFont(name: MercadoPagoContext.getDecorationPreference().getFontName(), size: 18) {
                titleDict = [NSForegroundColorAttributeName: UIColor.systemFontColor(), NSFontAttributeName: font]
            }
            
            
            if self.navigationController != nil {
                self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
                self.navigationItem.hidesBackButton = true
                self.navigationController!.interactivePopGestureRecognizer?.delegate = self
                self.navigationController?.navigationBar.tintColor = UIColor.systemFontColor()
                self.navigationController?.navigationBar.barTintColor = UIColor.primaryColor()
                self.navigationController?.navigationBar.removeBottomLine()
                self.navigationController?.navigationBar.isTranslucent = false
                //Create navigation buttons
                displayBackButton()
            }
            


        }
        
    }

    open func updateCardSkin() {
        
        if(self.paymentMethod != nil){
            
            self.cardFront?.cardLogo.image =  (paymentMethod?.getImage(bin: nil))
            self.cardView.backgroundColor =  (paymentMethod?.getColor(bin: nil))
            self.cardFront?.cardLogo.alpha = 1
            self.fontColor = (paymentMethod?.getFontColor(bin: nil))!
            cardFront?.cardName.text = " "
            cardFront?.cardExpirationDate.text = " "
            let labelMask = (paymentMethod?.getLabelMask(bin: nil) != nil) ? paymentMethod?.getLabelMask(bin: nil) : "XXXX XXXX XXXX XXXX"
            let textMaskFormaterAux = TextMaskFormater(mask: labelMask, leftToRight:false)
            cardFront?.cardNumber.text =  textMaskFormaterAux.textMasked((self.token!.lastFourDigits as String))

        
                
            if self.token?.cardHolder != nil {
                cardFront?.cardName.text = self.token!.cardHolder!.name
            }
            if ((self.token!.getExpirationDateFormated() as String).characters.count > 0 ){
                cardFront?.cardExpirationDate.text = self.token!.getExpirationDateFormated() as String
            }
            
            cardFront?.cardNumber.alpha = 0.7
            cardFront?.cardName.alpha = 0.7
            cardFront?.cardExpirationDate.alpha = 0.7
            cardFront?.cardNumber.textColor =  fontColor
            cardFront?.cardName.textColor =  fontColor
            cardFront?.cardExpirationDate.textColor =  fontColor
        }
        
    }

    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.primaryColor()
        tableView.tableFooterView = UIView()
        cardFront = CardFrontView(frame: self.cardView.bounds)
        cardFront?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let installmentNib = UINib(nibName: "InstallmentSelectionTableViewCell", bundle: self.bundle)
        self.tableView.register(installmentNib, forCellReuseIdentifier: "installmentCell")
        updateCardSkin()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cardView.addSubview(cardFront!)
        if(self.payerCosts == nil){
            self.getInstallments()
        }else{
            self.tableView.reloadData()
        }
        
    }
    
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    
    open func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
       
        return 50
    }
    
    open func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(self.payerCosts == nil){
            return 0
        }else{
            return installments![0].numberOfPayerCostToShow(maxInstallments)
        }
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let payerCost : PayerCost = payerCosts![(indexPath as NSIndexPath).row]
        let installmentCell = tableView.dequeueReusableCell(withIdentifier: "installmentCell", for: indexPath) as! InstallmentSelectionTableViewCell
        installmentCell.fillCell(payerCost)
  
        
        ViewUtils.drawBottomLine(y : 50, width: self.view.bounds.width, inView: installmentCell)

        return installmentCell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let payerCost : PayerCost = payerCosts![(indexPath as NSIndexPath).row]
        self.callback!(payerCost)
    }
    
    fileprivate func getInstallments(){
        let bin = token?.getBin() ?? ""
        MPServicesBuilder.getInstallments(bin, amount: self.amount, issuer: self.issuer, paymentMethodId: self.paymentMethod!._id, success: { (installments) -> Void in
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
    
    








