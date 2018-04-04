//
//  PromosTyCViewController.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 22/5/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import UIKit

open class PromosTyCViewController: MercadoPagoUIViewController, UITableViewDataSource, UITableViewDelegate {

    /*
	private lazy var __once: () = {
			let sizingCell = PromosTyCViewController.tableView.dequeueReusableCell(withIdentifier: "PromoTyCDetailTableViewCell") as? PromoTyCDetailTableViewCell
		}()
 */

	@IBOutlet weak fileprivate var tableView: UITableView!

	var promos: [BankDeal]!

	var bundle: Bundle? = MercadoPago.getBundle()

	public init(promos: [BankDeal]) {
		super.init(nibName: "PromosTyCViewController", bundle: self.bundle)
		self.promos = promos
	}

	public init() {
		super.init(nibName: "PromosTyCViewController", bundle: self.bundle)
	}

	override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}

	required public init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

    override open func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Promociones".localized

		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: UIBarButtonItemStyle.plain, target: nil, action: nil)

		self.tableView.register(UINib(nibName: "PromoTyCDetailTableViewCell", bundle: self.bundle), forCellReuseIdentifier: "PromoTyCDetailTableViewCell")

		self.tableView.estimatedRowHeight = 44.0
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.delegate = self
		self.tableView.dataSource = self

		self.tableView.reloadData()

    }

	open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.promos.count
	}

	open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tycCell = self.tyCCellAtIndexPath(indexPath) else { return UITableViewCell.init() }
        return tycCell
	}

	open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return self.heightForTyCCellAtIndexPath(indexPath)
	}

	func heightForTyCCellAtIndexPath(_ indexPath: IndexPath) -> CGFloat {
		let sizingCell: PromoTyCDetailTableViewCell? = nil
		self.configureTyCCell(sizingCell!, atIndexPath: indexPath)
		return self.calculateHeightForConfiguredSizingCell(sizingCell!)
	}

	func calculateHeightForConfiguredSizingCell(_ sizingCell: UITableViewCell) -> CGFloat {
		sizingCell.setNeedsLayout()
		sizingCell.layoutIfNeeded()
		let size = sizingCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
		return size.height + 1
	}

	func tyCCellAtIndexPath(_ indexPath: IndexPath) -> PromoTyCDetailTableViewCell? {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "PromoTyCDetailTableViewCell", for: indexPath) as? PromoTyCDetailTableViewCell else { return nil }
		self.configureTyCCell(cell, atIndexPath: indexPath)
		return cell
	}

	func configureTyCCell(_ cell: PromoTyCDetailTableViewCell, atIndexPath: IndexPath) {
		let promo = self.promos[(atIndexPath as NSIndexPath).row]
		self.setTyCForCell(cell, promo: promo)
	}

	func setTyCForCell(_ cell: PromoTyCDetailTableViewCell, promo: BankDeal) {
		cell.setLabelWithIssuerName(promo.issuer!.name!, legals: promo.legals)
	}

}
