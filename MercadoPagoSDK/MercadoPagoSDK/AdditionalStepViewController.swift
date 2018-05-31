//
//  AdditionalStepViewController.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/13/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers
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
        let bankInsterestNib = UINib(nibName: "BankInsterestTableViewCell", bundle: self.bundle)
        self.tableView.register(bankInsterestNib, forCellReuseIdentifier: "bankInsterestNib")
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavBar()
        self.navigationItem.leftBarButtonItem!.action = #selector(invokeCallbackCancel)
        self.extendedLayoutIncludesOpaqueBars = true
        self.titleCellHeight = 44

        if self.viewModel.showFloatingTotalRow() {
            getTableViewPinBottomContraint()?.isActive = false
            renderViews()
        } else {
            getTableViewPinBottomContraint()?.isActive = true
        }
    }

    func getTableViewPinBottomContraint() -> NSLayoutConstraint? {
        let filteredConstraints = self.view.constraints.filter { $0.identifier == "table_view_pin_bottom" }
        if let bottomContraint = filteredConstraints.first {
            return bottomContraint
        }
        return nil
    }

    fileprivate func renderViews() {
        var floatingButtonView: UIView!
        floatingButtonView = getFloatingButtonView()
        self.view.addSubview(floatingButtonView)
        PXLayout.setHeight(owner: floatingButtonView, height: 82 + PXLayout.getSafeAreaBottomInset()/2).isActive = true
        PXLayout.matchWidth(ofView: floatingButtonView).isActive = true
        PXLayout.centerHorizontally(view: floatingButtonView).isActive = true
        PXLayout.pinBottom(view: floatingButtonView, to: view, withMargin: 0).isActive = true
        PXLayout.put(view: floatingButtonView, onBottomOf: self.tableView).isActive = true
    }

    fileprivate func getFloatingButtonView() -> UIView {


        let amountFontSize: CGFloat = PXLayout.M_FONT
        let centsFontSize: CGFloat = PXLayout.XXXS_FONT
        let currency = MercadoPagoContext.getCurrency()


        let oldAmount = Utils.getAttributedAmount((self.viewModel.discount?.amountWithoutDiscount)!, currency: currency, color: UIColor.red, fontSize: PXLayout.XXS_FONT, baselineOffset: 4)

        oldAmount.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSRange(location: 0, length: oldAmount.length))




        let currencySymbol = currency.getCurrencySymbolOrDefault()
        let thousandSeparator = currency.getThousandsSeparatorOrDefault()
        let decimalSeparator = currency.getDecimalSeparatorOrDefault()

        let discountAmount = self.viewModel.discount?.amount_off.toAttributedString()

        let attributedAmount = Utils.getAttributedAmount(self.viewModel.amount, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator, currencySymbol: currencySymbol, color: .black, fontSize: amountFontSize, centsFontSize: centsFontSize, baselineOffset: 3, smallSymbol: false)

        oldAmount.append(" ".toAttributedString())
        oldAmount.append(attributedAmount)


        let action = PXComponentAction(label: "Descuento") {
            PXComponentFactory.Modal.show(viewController: CouponDetailViewController.init(coupon: self.viewModel.discount!), title: self.viewModel.discount?.getDescription())
        }

        let props = PXTotalRowProps(title: "Total".toAttributedString(), disclaimer: "disclaimer".toAttributedString(), mainValue: "main".toAttributedString(), secondaryValue: "secondary".toAttributedString())
        let total = PXTotalRowComponent(props: props)
        let totalView = total.render()
        return totalView
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
