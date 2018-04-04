//
//  PromoViewController.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 22/5/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import UIKit
import Foundation
import MercadoPagoPXTracking

open class PromoViewController: MercadoPagoUIViewController, UITableViewDataSource, UITableViewDelegate {

	var publicKey: String?
	override open var screenName: String { return TrackingUtil.SCREEN_NAME_BANK_DEALS }
    override open var screenId: String { return TrackingUtil.SCREEN_ID_BANK_DEALS }

	@IBOutlet weak fileprivate var tableView: UITableView!

	var promos: [BankDeal]!

	var bundle: Bundle? = MercadoPago.getBundle()
    var callback: (() -> Void)?

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	public init(promos: [BankDeal], callback: (() -> Void)? = nil) {
		super.init(nibName: "PromoViewController", bundle: self.bundle)
		self.publicKey = MercadoPagoContext.publicKey()
        self.callback = callback
        self.promos = promos
	}

	override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Promociones".localized

		self.tableView.register(UINib(nibName: "PromoTableViewCell", bundle: self.bundle), forCellReuseIdentifier: "PromoTableViewCell")
		self.tableView.register(UINib(nibName: "PromosTyCTableViewCell", bundle: self.bundle), forCellReuseIdentifier: "PromosTyCTableViewCell")
		self.tableView.register(UINib(nibName: "PromoEmptyTableViewCell", bundle: self.bundle), forCellReuseIdentifier: "PromoEmptyTableViewCell")

		self.tableView.estimatedRowHeight = 44.0
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.delegate = self
		self.tableView.dataSource = self

        if self.callback == nil {
            self.callback = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

	open func back() {
		self.dismiss(animated: true, completion: nil)
	}

	open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return promos == nil ? 1 : promos.count + 1
	}

	open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if self.promos != nil && self.promos.count > 0 {
			if (indexPath as NSIndexPath).row < self.promos.count {
				let promoCell: PromoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PromoTableViewCell", for: indexPath) as! PromoTableViewCell
				promoCell.setPromoInfo(self.promos[(indexPath as NSIndexPath).row])
				return promoCell
			} else {
				return tableView.dequeueReusableCell(withIdentifier: "PromosTyCTableViewCell", for: indexPath) as! PromosTyCTableViewCell
			}
		} else {
			return tableView.dequeueReusableCell(withIdentifier: "PromoEmptyTableViewCell", for: indexPath) as! PromoEmptyTableViewCell
		}
	}

	open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if self.promos != nil && self.promos.count > 0 {
			if (indexPath as NSIndexPath).row == self.promos.count {
				return 55
			} else {
				return 151
			}
		} else {
			return 80
		}
	}

	open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		if (indexPath as NSIndexPath).row == self.promos.count {
			self.navigationController?.pushViewController(PromosTyCViewController(promos: self.promos), animated: true)
		}

	}

    internal override func executeBack() {
            if self.callback != nil {
                self.callback!()
            }
    }

}
