//
//  AdditionalStepViewController.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/13/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class AdditionalStepViewController: MercadoPagoUIScrollViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var bundle: Bundle? = MercadoPago.getBundle()
    open let viewModel: AdditionalStepViewModel!
    override var maxFontSize: CGFloat { return self.viewModel.maxFontSize}

    override open var screenName: String { return viewModel.getScreenName() }
    override open var screenId: String { return viewModel.getScreenId() }

    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        loadMPStyles()

        var upperFrame = UIScreen.main.bounds
        upperFrame.origin.y = -upperFrame.size.height
        let upperView = UIView(frame: upperFrame)
        upperView.backgroundColor = UIColor.primaryColor()
        tableView.addSubview(upperView)

        self.showNavBar()
        loadCells()
    }

    func loadCells() {
        let titleNib = UINib(nibName: "AdditionalStepTitleTableViewCell", bundle: self.bundle)
        self.tableView.register(titleNib, forCellReuseIdentifier: "titleNib")
        let cardNib = UINib(nibName: "AdditionalStepCardTableViewCell", bundle: self.bundle)
        self.tableView.register(cardNib, forCellReuseIdentifier: "cardNib")
        let totalRowNib = UINib(nibName: "TotalPayerCostRowTableViewCell", bundle: self.bundle)
        self.tableView.register(totalRowNib, forCellReuseIdentifier: "totalRowNib")
        let bankInsterestNib = UINib(nibName: "BankInsterestTableViewCell", bundle: self.bundle)
        self.tableView.register(bankInsterestNib, forCellReuseIdentifier: "bankInsterestNib")
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavBar()
        self.navigationItem.leftBarButtonItem!.action = #selector(invokeCallbackCancel)
        self.extendedLayoutIncludesOpaqueBars = true
        self.titleCellHeight = 44
    }

    override func loadMPStyles() {
        if self.navigationController != nil {
            self.navigationController?.navigationBar.tintColor = UIColor(red: 255, green: 255, blue: 255)
            self.navigationController?.navigationBar.barTintColor = UIColor.primaryColor()
            self.navigationController?.navigationBar.removeBottomLine()
            self.navigationController?.navigationBar.isTranslucent = false

            displayBackButton()
        }
    }

    override func trackInfo() {
        viewModel.track()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(viewModel: AdditionalStepViewModel, callback: @escaping ((_ callbackData: NSObject) -> Void)) {
        self.viewModel = viewModel
        self.viewModel.callback = callback
        super.init(nibName: "AdditionalStepViewController", bundle: self.bundle)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.heightForRowAt(indexPath: indexPath)
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.viewModel.numberOfRowsInSection(section: section)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellWidth = self.tableView.bounds.width

        if viewModel.isTitleCellFor(indexPath: indexPath) {

            let titleCell = tableView.dequeueReusableCell(withIdentifier: "titleNib", for: indexPath as IndexPath) as! AdditionalStepTitleTableViewCell
            titleCell.selectionStyle = .none
            titleCell.setTitle(string: self.getNavigationBarTitle())
            titleCell.backgroundColor = UIColor.primaryColor()
            self.titleCell = titleCell

            return titleCell

        } else if viewModel.isCardCellFor(indexPath: indexPath) {

            let cardSectionCell = tableView.dequeueReusableCell(withIdentifier: "cardNib", for: indexPath as IndexPath) as! AdditionalStepCardTableViewCell
            cardSectionCell.selectionStyle = .none
            cardSectionCell.backgroundColor = UIColor.primaryColor()

            if viewModel.showCardSection(), let cellView = viewModel.getCardSectionView() {
                cardSectionCell.loadCellView(view: cellView as? UIView)
                cardSectionCell.updateCardSkin(token: self.viewModel.token, paymentMethod: self.viewModel.paymentMethods[0], view: cellView)
            }

            return cardSectionCell

        } else if viewModel.isBankInterestCellFor(indexPath: indexPath) {
            let bankInsterestCell = tableView.dequeueReusableCell(withIdentifier: "bankInsterestNib", for: indexPath as IndexPath) as! BankInsterestTableViewCell
                bankInsterestCell.backgroundColor = UIColor.primaryColor()
            return bankInsterestCell

        } else if viewModel.isDiscountCellFor(indexPath: indexPath) {
            let cell = UITableViewCell.init(style: .default, reuseIdentifier: "CouponCell")
            cell.contentView.viewWithTag(1)?.removeFromSuperview()
            let discountBody = DiscountBodyCell(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: DiscountBodyCell.HEIGHT), coupon: self.viewModel.discount, amount: self.viewModel.amount)
            discountBody.tag = 1
            cell.contentView.addSubview(discountBody)
            cell.selectionStyle = .none
            return cell

        } else if viewModel.isTotalCellFor(indexPath: indexPath) {
            let cellHeight = Double(viewModel.getAmountDetailCellHeight(indexPath: indexPath))
            let totalCell = tableView.dequeueReusableCell(withIdentifier: "totalRowNib", for: indexPath as IndexPath) as! TotalPayerCostRowTableViewCell
            totalCell.fillCell(total: self.viewModel.amount)
            totalCell.addSeparatorLineToBottom(width: Double(cellWidth), height: cellHeight)
            totalCell.selectionStyle = .none
            return totalCell as UITableViewCell

        } else if viewModel.isBodyCellFor(indexPath: indexPath) {
            let object = self.viewModel.dataSource[indexPath.row]
            let cell = AdditionalStepCellFactory.buildCell(object: object, width: Double(cellWidth), height: Double(viewModel.getDefaultRowCellHeight()))
            return cell
        }
        return UITableViewCell()
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if viewModel.isBodyCellFor(indexPath: indexPath) {
            let callbackData: NSObject = self.viewModel.dataSource[indexPath.row] as! NSObject
            self.viewModel.callback!(callbackData)

        }
        if self.viewModel.isDiscountCellFor(indexPath: indexPath) {
            if let coupon = self.viewModel.discount {
                let step = CouponDetailViewController(coupon: coupon)
                DispatchQueue.main.async {
                    self.present(step, animated: false, completion: {})
                }
            } else {
                let step = AddCouponViewController(amount: self.viewModel.amount, email: self.viewModel.email!, mercadoPagoServicesAdapter: self.viewModel.mercadoPagoServicesAdapter, callback: { [weak self](coupon) in
                    let couponDataDict: [String: DiscountCoupon] = ["coupon": coupon]

                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MPSDK_UpdateCoupon"), object: nil, userInfo: couponDataDict)

                    self?.viewModel.discount = coupon

                    if let updateMercadoPagoCheckout = self?.viewModel.couponCallback {
                        updateMercadoPagoCheckout(coupon)
                    }
                })

                self.navigationController?.pushViewController(step, animated: true)
            }

        }

    }

    public func updateDataSource(dataSource: [Cellable]) {
        self.viewModel.dataSource = dataSource
        self.tableView.reloadData()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.didScrollInTable(scrollView)
        let visibleIndexPaths = tableView.indexPathsForVisibleRows!
        for index in visibleIndexPaths where index.section == 1 {
            if let card = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? AdditionalStepCardTableViewCell {
                if tableView.contentOffset.y > 0 {
                    if 44 / tableView.contentOffset.y < 0.265 && !scrollingDown {
                        card.fadeCard()
                    } else {
                        if let container = card.containerView {
                            container.alpha = 44/tableView.contentOffset.y
                        }
                    }
                }
            }
        }
    }

    override func getNavigationBarTitle() -> String {
        return self.viewModel.getTitle()
    }

}
