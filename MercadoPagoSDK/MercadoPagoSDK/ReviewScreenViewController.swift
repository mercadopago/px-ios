//
//  ReviewScreenViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 13/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoPXTracking

open class ReviewScreenViewController: MercadoPagoUIScrollViewController, UITableViewDataSource, UITableViewDelegate, TermsAndConditionsDelegate, MPCustomRowDelegate, UnlockCardDelegate {

    var floatingConfirmButtonView: UIView!
    var fixedButton: UIButton?
    var floatingButton: UIButton?

    static let kNavBarOffset = CGFloat(-64.0)
    static let kDefaultNavBarOffset = CGFloat(0.0)
    var preferenceId: String!
    var publicKey: String!
    var accessToken: String!
    var bundle: Bundle? = MercadoPago.getBundle()
    var callbackPaymentData: ((PaymentData) -> Void)!
    var callbackConfirm: ((PaymentData) -> Void)!
    var callbackExit: (() -> Void)!
    var viewModel: CheckoutViewModel!
    override open var screenName: String { get { return TrackingUtil.SCREEN_NAME_REVIEW_AND_CONFIRM } }
    override open var screenId: String { get { return TrackingUtil.SCREEN_ID_REVIEW_AND_CONFIRM } }
    fileprivate var reviewAndConfirmContent = Set<String>()
    private var statusBarView: UIView?

    fileprivate var recover = false
    fileprivate var auth = false

    @IBOutlet weak var checkoutTable: UITableView!

   public init(viewModel: CheckoutViewModel, callbackPaymentData : @escaping (PaymentData) -> Void, callbackExit :@escaping (() -> Void), callbackConfirm : @escaping (PaymentData) -> Void) {
        super.init(nibName: "ReviewScreenViewController", bundle: MercadoPago.getBundle())
        self.initCommon()
        self.viewModel = viewModel
        self.callbackPaymentData = callbackPaymentData
        self.callbackExit = callbackExit
        self.callbackConfirm = callbackConfirm
    }

    private func initCommon() {
        MercadoPagoContext.clearPaymentKey()
        self.publicKey = MercadoPagoContext.publicKey()
        self.accessToken = MercadoPagoContext.merchantAccessToken()
    }
    override func trackInfo() {
        guard let paymentMethod = self.viewModel.paymentData.getPaymentMethod() else {
            return
        }
        var metadata = [TrackingUtil.METADATA_SHIPPING_INFO: TrackingUtil.HAS_SHIPPING_DEFAULT_VALUE, TrackingUtil.METADATA_PAYMENT_TYPE_ID: paymentMethod.paymentTypeId, TrackingUtil.METADATA_PAYMENT_METHOD_ID: paymentMethod._id]

        if let issuer = self.viewModel.paymentData.getIssuer() {
            metadata[TrackingUtil.METADATA_ISSUER_ID] = issuer._id
        }
        MPXTracker.trackScreen(screenId: screenId, screenName: screenName, metadata: metadata)
    }

    override func loadMPStyles() {
        self.setNavBarBackgroundColor(color : UIColor.px_white())
        super.loadMPStyles()
    }

    required public init?(coder aDecoder: NSCoder) {
        MercadoPagoContext.clearPaymentKey()
        fatalError("init(coder:) has not been implemented")
    }

    override func showNavBar() {

        super.showNavBar()

        if self.statusBarView == nil {
            self.displayStatusBar()
        }
    }

    var paymentEnabled = true

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        self.navigationItem.rightBarButtonItem = nil
        self.navBarTextColor = UIColor.primaryColor()

        self.displayBackButton()

        self.checkoutTable.dataSource = self
        self.checkoutTable.delegate = self

        self.registerAllCells()

        self.displayFloatingConfirmButton()
        self.displayStatusBar()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.showLoading()

        self.titleCellHeight = 44

        self.hideNavBar()

        self.checkoutTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.checkoutTable.bounds.size.width, height: 0.01))

        //TODO : OJO TOKEN RECUPERABLE
        if self.viewModel.paymentData.hasPaymentMethod() {
            //  self.checkoutTable.reloadData()
            if recover {
                recover = false
                //self.startRecoverCard()
            }
            if auth {
                auth = false
                //self.startAuthCard(self.viewModel.paymentData.token!)
            }
        }

        self.extendedLayoutIncludesOpaqueBars = true

        self.navBarTextColor = UIColor.primaryColor()

        if self.shouldShowNavBar(self.checkoutTable) {
            self.showNavBar()
        }
        self.hideLoading()

    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.heightForRow(indexPath)
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRowsInSection(section: section)
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if viewModel.isTitleCellFor(indexPath: indexPath) {
            return getMainTitleCell(indexPath : indexPath)

        } else if self.viewModel.isSummaryCellFor(indexPath: indexPath) {
            return self.getSummaryCell(indexPath: indexPath)

        } else if self.viewModel.isItemCellFor(indexPath: indexPath) {
            return viewModel.hasCustomItemCells() ? self.getCustomItemCell(indexPath: indexPath) : self.getPurchaseItemDetailCell(indexPath: indexPath)

        } else if viewModel.isPaymentMethodCellFor(indexPath: indexPath) {
            if self.viewModel.isPaymentMethodSelectedCard() {
                return self.getOnlinePaymentMethodSelectedCell(indexPath: indexPath)
            }
            return self.getOfflinePaymentMethodSelectedCell(indexPath: indexPath)

        } else if viewModel.isAddtionalCustomCellsFor(indexPath: indexPath) {
            return self.getCustomAdditionalCell(indexPath: indexPath)

        } else if viewModel.isTermsAndConditionsViewCellFor(indexPath: indexPath) {
            return self.getTermsAndConditionsCell(indexPath: indexPath)

        } else if viewModel.isConfirmButtonCellFor(indexPath: indexPath) {
            let cell = self.getConfirmPaymentButtonCell(indexPath: indexPath) as! ConfirmPaymentTableViewCell
            self.fixedButton = cell.confirmPaymentButton
            return cell

        } else if viewModel.isExitButtonTableViewCellFor(indexPath: indexPath) {
            return self.getCancelPaymentButtonCell(indexPath: indexPath)
        }

        return UITableViewCell()
    }

    @objc fileprivate func confirmPayment() {

        self.hideNavBar()
        self.hideBackButton()
        self.callbackConfirm(self.viewModel.paymentData)
    }

    fileprivate func registerAllCells() {

        //Register rows
        let AdditionalStepTitleTableViewCell = UINib(nibName: "AdditionalStepTitleTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(AdditionalStepTitleTableViewCell, forCellReuseIdentifier: "AdditionalStepTitleTableViewCell")

        let purchaseDetailTableViewCell = UINib(nibName: "PurchaseDetailTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(purchaseDetailTableViewCell, forCellReuseIdentifier: "purchaseDetailTableViewCell")

        let confirmPaymentTableViewCell = UINib(nibName: "ConfirmPaymentTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(confirmPaymentTableViewCell, forCellReuseIdentifier: "confirmPaymentTableViewCell")

        let purchaseItemDetailTableViewCell = UINib(nibName: "PurchaseItemDetailTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(purchaseItemDetailTableViewCell, forCellReuseIdentifier: "purchaseItemDetailTableViewCell")

        let purchaseItemDescriptionTableViewCell = UINib(nibName: "PurchaseItemDescriptionTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(purchaseItemDescriptionTableViewCell, forCellReuseIdentifier: "purchaseItemDescriptionTableViewCell")

        let purchaseSimpleDetailTableViewCell = UINib(nibName: "PurchaseSimpleDetailTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(purchaseSimpleDetailTableViewCell, forCellReuseIdentifier: "purchaseSimpleDetailTableViewCell")

        let purchaseItemAmountTableViewCell = UINib(nibName: "PurchaseItemAmountTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(purchaseItemAmountTableViewCell, forCellReuseIdentifier: "purchaseItemAmountTableViewCell")

        let paymentMethodSelectedTableViewCell = UINib(nibName: "PaymentMethodSelectedTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(paymentMethodSelectedTableViewCell, forCellReuseIdentifier: "paymentMethodSelectedTableViewCell")

        let exitButtonCell = UINib(nibName: "ExitButtonTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(exitButtonCell, forCellReuseIdentifier: "exitButtonCell")

        let offlinePaymentMethodCell = UINib(nibName: "OfflinePaymentMethodCell", bundle: self.bundle)
        self.checkoutTable.register(offlinePaymentMethodCell, forCellReuseIdentifier: "offlinePaymentMethodCell")

        let purchaseTermsAndConditions = UINib(nibName: "TermsAndConditionsViewCell", bundle: self.bundle)
        self.checkoutTable.register(purchaseTermsAndConditions, forCellReuseIdentifier: "termsAndConditionsViewCell")

        let purchaseUnlockCard = UINib(nibName: "UnlockCardTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(purchaseUnlockCard, forCellReuseIdentifier: "unlockCardTableViewCell")

        let confirmAdditionalInfoCFT = UINib(nibName: "ConfirmAdditionalInfoTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(confirmAdditionalInfoCFT, forCellReuseIdentifier: "confirmAdditionalInfoCFT")

        self.checkoutTable.delegate = self
        self.checkoutTable.dataSource = self
        self.checkoutTable.separatorStyle = .none
    }

    private func getMainTitleCell(indexPath: IndexPath) -> UITableViewCell {
        let AdditionalStepTitleTableViewCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "AdditionalStepTitleTableViewCell", for: indexPath) as! AdditionalStepTitleTableViewCell
        AdditionalStepTitleTableViewCell.setTitle(string: viewModel.reviewScreenPreference.getTitle())
        AdditionalStepTitleTableViewCell.title.textColor = UIColor.primaryColor()
        AdditionalStepTitleTableViewCell.cell.backgroundColor = UIColor.px_white()
        titleCell = AdditionalStepTitleTableViewCell
        return AdditionalStepTitleTableViewCell
    }

    private func getPurchaseDetailCell(indexPath: IndexPath, title: String, amount: Double, payerCost: PayerCost? = nil, addSeparatorLine: Bool = true) -> UITableViewCell {
        let currency = MercadoPagoContext.getCurrency()
        if self.viewModel.shouldDisplayNoRate() {
            let purchaseDetailCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "purchaseDetailTableViewCell", for: indexPath) as! PurchaseDetailTableViewCell
            purchaseDetailCell.fillCell(title, amount: amount, currency: currency, payerCost: payerCost)
            return purchaseDetailCell
        }

        return getPurchaseSimpleDetailCell(indexPath: indexPath, title: title, amount: amount, payerCost : payerCost, addSeparatorLine: addSeparatorLine)
    }

    private func getCustomAdditionalCell(indexPath: IndexPath) -> UITableViewCell {
        return makeCellWith(customCell: viewModel.reviewScreenPreference.additionalInfoCells[indexPath.row], indentifier: "CustomAppCell")
    }

    private func getCustomItemCell(indexPath: IndexPath) -> UITableViewCell {
        return makeCellWith(customCell: viewModel.reviewScreenPreference.customItemCells[indexPath.row], indentifier: "CustomItemCell")
    }

    private func makeCellWith(customCell: MPCustomCell, indentifier: String) -> UITableViewCell {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let customView = customCell.getTableViewCell().contentView
        customCell.setDelegate(delegate: self)
        let frame = customView.frame
        customView.frame = CGRect(x: (screenWidth - frame.size.width) / 2, y: 0, width: frame.size.width, height: customCell.getHeight())
        let cell = UITableViewCell(style: .default, reuseIdentifier: indentifier)
        cell.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        cell.contentView.addSubview(customView)
        cell.selectionStyle = .none
        let separatorLine = ViewUtils.getTableCellSeparatorLineView(0, y: customCell.getHeight()-1, width: screenWidth, height: 1)
        cell.addSubview(separatorLine)
        cell.contentView.backgroundColor = customView.backgroundColor
        cell.clipsToBounds = true
        return cell
    }

    private func getSummaryCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "summaryComponentCell")
        cell.contentView.addSubview(self.viewModel.summaryComponent)
        cell.selectionStyle = .none
        return cell
    }

    private func getPurchaseSimpleDetailCell(indexPath: IndexPath, title: String, amount: Double, payerCost: PayerCost? = nil, addSeparatorLine: Bool = true) -> UITableViewCell {
        let currency = MercadoPagoContext.getCurrency()
        let purchaseSimpleDetailTableViewCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "purchaseSimpleDetailTableViewCell", for: indexPath) as! PurchaseSimpleDetailTableViewCell
        purchaseSimpleDetailTableViewCell.fillCell(title, amount: amount, currency: currency, payerCost: payerCost, addSeparatorLine : addSeparatorLine, height: PurchaseSimpleDetailTableViewCell.TOTAL_ROW_HEIGHT)
        return purchaseSimpleDetailTableViewCell
    }

    private func getConfirmAdditionalInfo( indexPath: IndexPath, payerCost: PayerCost?) -> UITableViewCell {
        let confirmAdditionalInfoCFT = self.checkoutTable.dequeueReusableCell(withIdentifier: "confirmAdditionalInfoCFT", for: indexPath) as! ConfirmAdditionalInfoTableViewCell
        confirmAdditionalInfoCFT.fillCell(payerCost: payerCost)
        return confirmAdditionalInfoCFT
    }

    private func getConfirmPaymentButtonCell(indexPath: IndexPath) -> UITableViewCell {
        let confirmPaymentTableViewCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "confirmPaymentTableViewCell", for: indexPath) as! ConfirmPaymentTableViewCell
        confirmPaymentTableViewCell.confirmPaymentButton.addTarget(self, action: #selector(confirmPayment), for: .touchUpInside)
        let confirmPaymentTitle = viewModel.reviewScreenPreference.getConfirmButtonText()
        confirmPaymentTableViewCell.confirmPaymentButton.setTitle(confirmPaymentTitle, for: .normal)
        return confirmPaymentTableViewCell
    }

    private func getPurchaseItemDetailCell(indexPath: IndexPath) -> UITableViewCell {
        let currency = MercadoPagoContext.getCurrency()
        let purchaseItemDetailCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "purchaseItemDetailTableViewCell", for: indexPath) as! PurchaseItemDetailTableViewCell
        purchaseItemDetailCell.fillCell(item: self.viewModel.preference!.items[indexPath.row], currency: currency, quantityHidden: !self.viewModel.reviewScreenPreference.shouldShowQuantityRow, amountTittleHidden: !self.viewModel.reviewScreenPreference.shouldShowAmountTitle, quantityTitle: self.viewModel.reviewScreenPreference.getQuantityTitle(), amountTitle: self.viewModel.reviewScreenPreference.getAmountTitle())
        return purchaseItemDetailCell
    }

    private func getOnlinePaymentMethodSelectedCell(indexPath: IndexPath) -> UITableViewCell {
        let paymentMethodSelectedTableViewCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "paymentMethodSelectedTableViewCell", for: indexPath) as! PaymentMethodSelectedTableViewCell

        paymentMethodSelectedTableViewCell.fillCell(paymentData: self.viewModel.paymentData, amount : self.viewModel.getTotalAmount(), reviewScreenPreference: self.viewModel.reviewScreenPreference)

        paymentMethodSelectedTableViewCell.selectOtherPaymentMethodButton.addTarget(self, action: #selector(changePaymentMethodSelected), for: .touchUpInside)
        return paymentMethodSelectedTableViewCell
    }

    private func getOfflinePaymentMethodSelectedCell(indexPath: IndexPath) -> UITableViewCell {
        let offlinePaymentMethodCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "offlinePaymentMethodCell", for: indexPath) as! OfflinePaymentMethodCell
        offlinePaymentMethodCell.fillCell(self.viewModel.paymentOptionSelected, amount: self.viewModel.getTotalAmount(), paymentMethod : self.viewModel.paymentData.getPaymentMethod()!, currency: MercadoPagoContext.getCurrency(), reviewScreenPreference: self.viewModel.reviewScreenPreference)
        offlinePaymentMethodCell.changePaymentButton.addTarget(self, action: #selector(self.changePaymentMethodSelected), for: .touchUpInside)
        return offlinePaymentMethodCell
    }

    private func getCancelPaymentButtonCell(indexPath: IndexPath) -> UITableViewCell {
        let exitButtonCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "exitButtonCell", for: indexPath) as! ExitButtonTableViewCell
        let exitButtonTitle = viewModel.reviewScreenPreference.getCancelButtonTitle()
        exitButtonCell.exitButton.setTitle(exitButtonTitle, for: .normal)
        exitButtonCell.exitButton.addTarget(self, action: #selector(ReviewScreenViewController.exitCheckoutFlow), for: .touchUpInside)
        return exitButtonCell
    }

    private func getUnlockCardCell(indexPath: IndexPath) -> UITableViewCell {
        let unlockCardCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "unlockCardTableViewCell", for: indexPath) as! UnlockCardTableViewCell
        unlockCardCell.delegate = self
        return unlockCardCell
    }

    private func getTermsAndConditionsCell(indexPath: IndexPath) -> UITableViewCell {
        let tycCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "termsAndConditionsViewCell", for: indexPath) as! TermsAndConditionsViewCell
        tycCell.delegate = self
        return tycCell
    }

	@objc func changePaymentMethodSelected() {
        self.callbackPaymentData(self.viewModel.getClearPaymentData())
	}

    internal func openTermsAndConditions(_ title: String, url: URL) {
        let webVC = WebViewController(url: url, screenName: "TERMS_AND_CONDITIONS", navigationBarTitle: "Términos y Condiciones".localized)
        webVC.title = title
        self.navigationController!.pushViewController(webVC, animated: true)

    }

    internal func openUnlockCard(_ title: String, url: URL) {
        let webVC = WebViewController(url: url, screenName: "UNLOCK_CARD", navigationBarTitle: "Desbloqueo de Tarjeta".localized)
        webVC.title = title
        self.navigationController!.pushViewController(webVC, animated: true)

    }

    @objc internal func exitCheckoutFlow() {
        self.callbackExit()
    }

    override func getNavigationBarTitle() -> String {
        if self.checkoutTable != nil {
            if self.checkoutTable.contentOffset.y == ReviewScreenViewController.kNavBarOffset || self.checkoutTable.contentOffset.y == ReviewScreenViewController.kNavBarOffset {
                return ""
            }
            return viewModel.reviewScreenPreference.getTitle()
        }
        return ""
    }

    open func isConfirmButtonVisible() -> Bool {
        guard let floatingButton = self.floatingButton, let fixedButton = self.fixedButton else {
            return false
        }
        let floatingButtonCoordinates = floatingButton.convert(CGPoint.zero, from: self.view.window)
        let fixedButtonCoordinates = fixedButton.convert(CGPoint.zero, from: self.view.window)
        return fixedButtonCoordinates.y >= floatingButtonCoordinates.y
    }

    open func getFloatingButtonView() -> UIView {
        let frame = self.viewModel.getFloatingConfirmButtonViewFrame()
        let view = UIView(frame: frame)
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.25
        view.layer.masksToBounds = false
        view.clipsToBounds = false
        return view
    }

    open func getFloatingButtonCell() -> UITableViewCell {
        let indexPath = IndexPath(row: 0, section: 1)
        let frame = self.viewModel.getFloatingConfirmButtonCellFrame()
        let cell = self.getConfirmPaymentButtonCell(indexPath: indexPath) as! ConfirmPaymentTableViewCell
        cell.frame = frame
        self.floatingButton = cell.confirmPaymentButton
        return cell
    }

    open func displayFloatingConfirmButton() {
        if self.floatingConfirmButtonView != nil {
            return
        }
        self.floatingConfirmButtonView = self.getFloatingButtonView()
        let cell = self.getFloatingButtonCell()
        self.floatingConfirmButtonView.addSubview(cell)
        self.view.addSubview(floatingConfirmButtonView)
        self.view.bringSubview(toFront: floatingConfirmButtonView)
    }

    public func checkFloatingButtonVisibility() {
        if isConfirmButtonVisible() {
            self.floatingConfirmButtonView.isHidden = true
        } else {
            self.floatingConfirmButtonView.isHidden = false
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.checkFloatingButtonVisibility()
        self.didScrollInTable(scrollView)
    }

    public func invokeCallbackWithPaymentData(rowCallback: ((PaymentData) -> Void)) {
        rowCallback(self.viewModel.paymentData)
    }

    open override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        removeStatusBar()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeStatusBar()
    }

    private func removeStatusBar() {
        guard let _ = self.navigationController, let view = statusBarView else {
            return
        }
        view.removeFromSuperview()
    }

    private func displayStatusBar() {

        self.statusBarView = UIView(frame: CGRect(x: 0, y: -20, width: self.view.frame.width, height: 20))
        self.statusBarView!.backgroundColor = UIColor.grayStatusBar()
        self.statusBarView!.tag = 1
        self.navigationController!.navigationBar.barStyle = .blackTranslucent
        self.navigationController!.navigationBar.addSubview(self.statusBarView!)
    }
}

@objc public protocol MPCustomRowDelegate {

    @objc optional func invokeCallbackWithPaymentData(rowCallback: ((PaymentData) -> Void))

    @objc optional func invokeCallbackWithPaymentResult(rowCallback: ((PaymentResult) -> Void))

}
