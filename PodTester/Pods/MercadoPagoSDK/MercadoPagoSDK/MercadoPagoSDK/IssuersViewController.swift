//
//  IssuersViewController.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 9/1/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import UIKit

open class IssuersViewController: MercadoPagoUIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var publicKey : String?
    var paymentMethod: PaymentMethod?
    var callback: ((_ issuer: Issuer) -> Void)?
    
    @IBOutlet weak fileprivate var tableView : UITableView!
    var loadingView : UILoadingView!
    var items : [Issuer]!
     override open var screenName : String { get { return "CARD_ISSUER" } }
    var bundle: Bundle? = MercadoPago.getBundle()

    init(paymentMethod: PaymentMethod, callback: @escaping (_ issuer: Issuer) -> Void) {
        super.init(nibName: "IssuersViewController", bundle: bundle)
        self.publicKey = MercadoPagoContext.publicKey()
        self.paymentMethod = paymentMethod
        self.callback = callback
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Banco".localized
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás".localized, style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        let mercadoPago : MercadoPago = MercadoPago(publicKey: self.publicKey!)
        mercadoPago.getIssuers(self.paymentMethod!._id, success: { (issuers: [Issuer]?) -> Void in
                self.items = issuers
                self.tableView.reloadData()
                self.loadingView.removeFromSuperview()
            }, failure: nil)
        
        self.loadingView = UILoadingView(frame: MercadoPago.screenBoundsFixedToPortraitOrientation(), text: ("Cargando...".localized as NSString) as String)
        self.view.addSubview(self.loadingView)
        
        let issuerNib = UINib(nibName: "IssuerTableViewCell", bundle: self.bundle)
        self.tableView.register(issuerNib, forCellReuseIdentifier: "issuerCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items == nil ? 0 : items.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let issuerCell : IssuerTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "issuerCell") as! IssuerTableViewCell
        
        let issuer : Issuer = items[(indexPath as NSIndexPath).row]
        issuerCell.fillWithIssuer(issuer)
        return issuerCell
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callback!(self.items![(indexPath as NSIndexPath).row])
    }
    
    
    internal override func executeBack(){
        if self.callbackCancel != nil {
            self.callbackCancel!()
        }else{
            super.executeBack()
        }
        
    }

    
}
