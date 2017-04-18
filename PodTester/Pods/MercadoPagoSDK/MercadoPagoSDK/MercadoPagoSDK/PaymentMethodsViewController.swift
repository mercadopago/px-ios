//
//  PaymentMethodsViewController.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 9/1/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class PaymentMethodsViewController : MercadoPagoUIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var publicKey : String?
    
    @IBOutlet weak fileprivate var tableView : UITableView!
    var loadingView : UILoadingView!
    var items : [PaymentMethod]!
    var paymentPreference: PaymentPreference?
    var bundle : Bundle? = MercadoPago.getBundle()
    
    var callback : ((_ paymentMethod : PaymentMethod) -> Void)?
    
    init(paymentPreference: PaymentPreference?, callback:@escaping (_ paymentMethod: PaymentMethod) -> Void) {
        super.init(nibName: "PaymentMethodsViewController", bundle: bundle)
        self.publicKey = MercadoPagoContext.publicKey()
        self.paymentPreference = paymentPreference
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
        
        self.title = "Medio de pago".localized
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás".localized, style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        self.loadingView = UILoadingView(frame: MercadoPago.screenBoundsFixedToPortraitOrientation(), text: ("Cargando...".localized as NSString) as String)
        self.view.addSubview(self.loadingView)
        
        MPServicesBuilder.getPaymentMethods({(paymentMethods: [PaymentMethod]?) -> Void in
                self.items = [PaymentMethod]()
                if paymentMethods != nil {
                    if self.paymentPreference != nil {
                        var currenPaymentMethods = paymentMethods
                        if self.paymentPreference?.excludedPaymentTypeIds != nil && self.paymentPreference?.excludedPaymentTypeIds?.count > 0 {
                            currenPaymentMethods = currenPaymentMethods?.filter({return !(self.paymentPreference?.excludedPaymentTypeIds!.contains($0.paymentTypeId))!})
                        }
                        if self.paymentPreference?.excludedPaymentMethodIds != nil && self.paymentPreference?.excludedPaymentMethodIds?.count > 0 {
                            currenPaymentMethods = currenPaymentMethods?.filter({return !(self.paymentPreference?.excludedPaymentMethodIds?.contains($0._id))!})
                        }
                        self.items = currenPaymentMethods
                    } else {
                        self.items = paymentMethods
                    }
                }
            
                self.tableView.reloadData()
                self.loadingView.removeFromSuperview()
            }, failure: { (error: NSError?) -> Void in
                MercadoPago.showAlertViewWithError(error, nav: self.navigationController)
        })
        
        let paymentMethodNib = UINib(nibName: "PaymentMethodTableViewCell", bundle: self.bundle)
        self.tableView.register(paymentMethodNib, forCellReuseIdentifier: "paymentMethodCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items == nil ? 0 : items.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pmcell : PaymentMethodTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "paymentMethodCell") as! PaymentMethodTableViewCell
        
        let paymentMethod : PaymentMethod = items[(indexPath as NSIndexPath).row]
        pmcell.setLabel(paymentMethod.name)
        pmcell.setImageWithName(paymentMethod._id)
        
        return pmcell
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.callback!(self.items![(indexPath as NSIndexPath).row])
    }
    
    
    internal override func executeBack(){
        if self.callbackCancel != nil {
            self.callbackCancel!()
        }else{
            super.executeBack()
        }
    
    }
    
}
