//
//  IssuerCardViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 5/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class IssuerCardViewController: MercadoPagoUIViewController {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var bundle : Bundle? = MercadoPago.getBundle()
    var callback : (( _ issuer: Issuer) -> Void)?
    
    var cardToken : CardToken?
    var paymentMethod : PaymentMethod?
    var issuerList : [Issuer]?
    var cardFront : CardFrontView?
    var fontColor = UIColor(netHex:0x333333)
    
    override open var screenName : String { get { return "CARD_ISSUER" } }
    
    public init(paymentMethod: PaymentMethod,  cardToken: CardToken , issuerList: [Issuer]? = nil, callback : @escaping (( _ issuer: Issuer) -> Void)) {
        
        super.init(nibName: "IssuerCardViewController", bundle: MercadoPago.getBundle())
        
        self.edgesForExtendedLayout = UIRectEdge()
        self.cardToken = cardToken
        self.callback = callback
        self.paymentMethod = paymentMethod
        self.issuerList = issuerList
        
    }
    
    override func loadMPStyles(){
        
        if self.navigationController != nil {
            
            
            //Navigation bar colors
            let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.systemFontColor(), NSFontAttributeName: Utils.getFont(size: 18)]
            
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

    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cardView.addSubview(cardFront!)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.primaryColor()
         tableView.tableFooterView = UIView()
        let issuerNib = UINib(nibName: "IssuerTableViewCell", bundle: self.bundle)
        self.tableView.register(issuerNib, forCellReuseIdentifier: "issuerCell")
        cardFront = CardFrontView(frame: self.cardView.bounds)
        cardFront?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Do any additional setup after loading the view.
    }
    
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.leftBarButtonItem!.action = #selector(invokeCallbackCancel)
        
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
        
        if(self.issuerList == nil){
            return 0
        }else{
            return (issuerList?.count)!
        }
    }

    open func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let issuerCell : IssuerTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "issuerCell") as! IssuerTableViewCell
        
        let issuer : Issuer = issuerList![(indexPath as NSIndexPath).row]
        issuerCell.fillWithIssuer(issuer)
        return issuerCell
    }

    
    open func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        callback!(self.issuerList![(indexPath as NSIndexPath).row])
    }

}
