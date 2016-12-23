//
//  CustomerCardsViewController.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class CustomerCardsViewController : MercadoPagoUIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak fileprivate var tableView : UITableView!
    var loadingView : UILoadingView!
    var items : [PaymentMethodRow]!
    var cards : [Card]?
    var bundle : Bundle? = MercadoPago.getBundle()
    var callback : ((_ selectedCard: Card?) -> Void)?
    override open var screenName : String { get { return "CUSTOMER_CARDS" } }
    
    
    public init(cards: [Card]?, callback: @escaping (_ selectedCard: Card?) -> Void) {
        super.init(nibName: "CustomerCardsViewController", bundle: bundle)
        self.cards = cards
        self.callback = callback
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Medios de pago".localized

		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás".localized, style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(CustomerCardsViewController.newCard))

        self.loadingView = UILoadingView(frame: MercadoPago.screenBoundsFixedToPortraitOrientation(), text: ("Cargando...".localized as NSString) as String)
        self.view.addSubview(self.loadingView)
        
        let paymentMethodNib = UINib(nibName: "PaymentMethodTableViewCell", bundle: self.bundle)
        self.tableView.register(paymentMethodNib, forCellReuseIdentifier: "paymentMethodCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        loadCards()
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items == nil ? 0 : items.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pmcell : PaymentMethodTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "paymentMethodCell") as! PaymentMethodTableViewCell
        
        let paymentRow : PaymentMethodRow = items[(indexPath as NSIndexPath).row]
        pmcell.setLabel(paymentRow.label!)
        pmcell.setImageWithName(paymentRow.icon!)
        
        return pmcell
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callback!(self.cards![(indexPath as NSIndexPath).row])
    }
    
    open func loadCards() {
        self.items = [PaymentMethodRow]()
        for (card) in cards! {
            let paymentMethodRow = PaymentMethodRow()
            paymentMethodRow.card = card
            paymentMethodRow.label = card.paymentMethod!.name + " " + "terminada en".localized + " " + card.lastFourDigits!
            paymentMethodRow.icon = card.paymentMethod!._id
            self.items.append(paymentMethodRow)
        }
        self.tableView.reloadData()
        self.loadingView.removeFromSuperview()
    }
    
    open func newCard() {
        callback!(nil)
    }
}
