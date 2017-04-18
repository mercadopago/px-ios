//
//  CheckoutViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 13/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit


open class CheckoutViewController: MercadoPagoUIScrollViewController, UITableViewDataSource, UITableViewDelegate, TermsAndConditionsDelegate, MPCustomRowDelegate {

    static let kNavBarOffset = CGFloat(-64.0);
    static let kDefaultNavBarOffset = CGFloat(0.0);
    var preferenceId : String!
    var publicKey : String!
    var accessToken : String!
    var bundle : Bundle? = MercadoPago.getBundle()
    var callbackPaymentData : ((PaymentData) -> Void)!
    var callbackConfirm : ((PaymentData) -> Void)!
    var viewModel : CheckoutViewModel!
    override open var screenName : String { get{ return "REVIEW_AND_CONFIRM" } }
    fileprivate var reviewAndConfirmContent = Set<String>()
    private var statusBarView : UIView?
    
    fileprivate var recover = false
    fileprivate var auth = false
    
    @IBOutlet weak var checkoutTable: UITableView!
    
    init(viewModel: CheckoutViewModel, callbackPaymentData : @escaping (PaymentData) -> Void,  callbackCancel : @escaping ((Void) -> Void), callbackConfirm : @escaping (PaymentData) -> Void) {
        super.init(nibName: "CheckoutViewController", bundle: MercadoPago.getBundle())
        self.initCommon()
        self.viewModel = viewModel
        self.callbackPaymentData = callbackPaymentData
        self.callbackCancel = callbackCancel
        self.callbackConfirm = callbackConfirm
    }
    
    private func initCommon(){
        MercadoPagoContext.clearPaymentKey()
        self.publicKey = MercadoPagoContext.publicKey()
        self.accessToken = MercadoPagoContext.merchantAccessToken()
    }
    
    override func loadMPStyles(){
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
        self.navigationItem.leftBarButtonItem!.action = #selector(CheckoutViewController.exitCheckoutFlow)
        
        self.checkoutTable.dataSource = self
        self.checkoutTable.delegate = self
        
        self.registerAllCells()
        
        self.displayStatusBar()

        
    }

    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showLoading()
        
        
        self.titleCellHeight = 44
        
        
        self.hideNavBar()
        
        self.checkoutTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.checkoutTable.bounds.size.width, height: 0.01))
        
        if !self.viewModel.isPreferenceLoaded() {
            self.loadPreference()
        } else {
            //TODO : OJO TOKEN RECUPERABLE
            if self.viewModel.paymentData.paymentMethod != nil {
              //  self.checkoutTable.reloadData()
                if (recover){
                    recover = false
                    //self.startRecoverCard()
                }
                if (auth) {
                    auth = false
                    //self.startAuthCard(self.viewModel.paymentData.token!)
                }
            }
        }
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        self.navBarTextColor = UIColor.px_blueMercadoPago()
        
        if self.shouldShowNavBar(self.checkoutTable) {
            self.showNavBar()
        }
        self.hideLoading()
     
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.checkoutTableHeaderHeight(section)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.heightForRow(indexPath)
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1:
                // numberOfRowsInMainSection() + confirmPaymentButton
                return self.viewModel.numberOfRowsInMainSection() + 1
            case 2:
                return viewModel.hasCustomItemCells() ? viewModel.numberOfCustomItemCells() : self.viewModel.preference!.items.count
            case 3:
                return 1
            case 4:
                return self.viewModel.numberOfCustomAdditionalCells()
            case 5:
                // No mostrar TyC en caso de que se tenga AT
                return (String.isNullOrEmpty(MercadoPagoContext.payerAccessToken())) ? 3 : 2
            default:
                return 0
        }
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if viewModel.isTitleCellFor(indexPath: indexPath) {
            return getMainTitleCell(indexPath : indexPath)
            
        } else if self.viewModel.isProductlCellFor(indexPath: indexPath){
            return self.getSummaryCell(indexPath: indexPath)
            
        } else if self.viewModel.isInstallmentsCellFor(indexPath: indexPath) {
            return self.getPurchaseDetailCell(indexPath: indexPath, title : "Pagas".localized, amount : self.viewModel.preference!.getAmount(), payerCost : self.viewModel.paymentData.payerCost, addSeparatorLine: true)
            
        } else if self.viewModel.isTotalCellFor(indexPath: indexPath){
            return self.getPurchaseSimpleDetailCell(indexPath: indexPath, title : "Total".localized, amount : self.viewModel.getTotalAmount(), addSeparatorLine: false)
        
        } else if self.viewModel.isConfirmAdditionalInfoFor(indexPath: indexPath){
        return self.getConfirmAddtionalInfo(indexPath: indexPath, payerCost: self.viewModel.paymentData.payerCost)
        
        } else if self.viewModel.isConfirmButtonCellFor(indexPath: indexPath){
            return self.getConfirmPaymentButtonCell(indexPath: indexPath)
            
        } else if self.viewModel.isItemCellFor(indexPath: indexPath){
            return viewModel.hasCustomItemCells() ? self.getCustomItemCell(indexPath: indexPath) : self.getPurchaseItemDetailCell(indexPath: indexPath)
            
        } else if viewModel.isPaymentMethodCellFor(indexPath: indexPath) {
            if self.viewModel.isPaymentMethodSelectedCard() {
                return self.getOnlinePaymentMethodSelectedCell(indexPath: indexPath)
            }
            return self.getOfflinePaymentMethodSelectedCell(indexPath: indexPath)
            
        } else if viewModel.isAddtionalCustomCellsFor(indexPath: indexPath) {
            return self.getCustomAdditionalCell(indexPath: indexPath)
            
        } else if viewModel.isFotterCellFor(indexPath: indexPath) {
            switch indexPath.row {
            case 0 :
                if String.isNullOrEmpty(MercadoPagoContext.payerAccessToken()) {
                    return self.getTermsAndConditionsCell(indexPath: indexPath)
                }
                return self.getConfirmPaymentButtonCell(indexPath: indexPath)
            case 1 :
                if String.isNullOrEmpty(MercadoPagoContext.payerAccessToken()) {
                    return self.getConfirmPaymentButtonCell(indexPath: indexPath)
                }
                return self.getCancelPaymentButtonCell(indexPath: indexPath)
            default :
                return self.getCancelPaymentButtonCell(indexPath: indexPath)
            }
        }
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
    }
    
    @objc fileprivate func confirmPayment(){
        
        self.hideNavBar()
        self.hideBackButton()
        self.hideTimer()
        
        self.showLoading()

        self.callbackConfirm(self.viewModel.paymentData)
    }
 
    fileprivate func loadPreference() {
        MPServicesBuilder.getPreference(self.preferenceId, baseURL: MercadoPagoCheckoutViewModel.servicePreference.getDefaultBaseURL(), success: { (preference) in
                if let error = preference.validate() {
                    // Invalid preference - cannot continue
                    let mpError =  MPSDKError(message: "Hubo un error".localized, messageDetail: error.localized, retry: false)
                    self.displayFailure(mpError)
                } else {
                    self.viewModel.preference = preference
                    self.checkoutTable.reloadData()
                   // self.loadGroupsAndStartPaymentVault(false)
                }
            }, failure: { (error) in
                // Error in service - retry
                self.requestFailure(error, callback: {
                    self.loadPreference()
                    }, callbackCancel: {
                    self.navigationController!.dismiss(animated: true, completion: {})
                })
        })
    }

    fileprivate func registerAllCells(){
        
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
        
        let confirmAddtionalInfoCFT = UINib(nibName: "ConfirmAdditionalInfoTableViewCell", bundle: self.bundle)
        self.checkoutTable.register(confirmAddtionalInfoCFT, forCellReuseIdentifier: "confirmAddtionalInfoCFT")
        
        self.checkoutTable.delegate = self
        self.checkoutTable.dataSource = self
        self.checkoutTable.separatorStyle = .none
    }
    
    private func getMainTitleCell(indexPath : IndexPath) -> UITableViewCell{
        let AdditionalStepTitleTableViewCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "AdditionalStepTitleTableViewCell", for: indexPath) as! AdditionalStepTitleTableViewCell
        AdditionalStepTitleTableViewCell.setTitle(string: MercadoPagoCheckoutViewModel.reviewScreenPreference.getTitle())
        AdditionalStepTitleTableViewCell.title.textColor = UIColor.primaryColor()
        AdditionalStepTitleTableViewCell.cell.backgroundColor = UIColor.px_white()
        titleCell = AdditionalStepTitleTableViewCell
        return AdditionalStepTitleTableViewCell
    }
    
    private func getPurchaseDetailCell(indexPath : IndexPath, title : String, amount : Double, payerCost : PayerCost? = nil, addSeparatorLine : Bool = true) -> UITableViewCell{
        let currency = MercadoPagoContext.getCurrency()
        if self.viewModel.shouldDisplayNoRate() {
            let purchaseDetailCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "purchaseDetailTableViewCell", for: indexPath) as! PurchaseDetailTableViewCell
            purchaseDetailCell.fillCell(title, amount: amount, currency: currency, payerCost: payerCost)
            return purchaseDetailCell
        }
        
        return getPurchaseSimpleDetailCell(indexPath: indexPath, title: title, amount: amount, payerCost : payerCost, addSeparatorLine: addSeparatorLine)
    }
    
    private func getCustomAdditionalCell(indexPath: IndexPath) -> UITableViewCell{
        return makeCellWith(customCell: ReviewScreenPreference.additionalInfoCells[indexPath.row], indentifier: "CustomAppCell")
    }
    
    private func getCustomItemCell(indexPath: IndexPath) -> UITableViewCell{
        return makeCellWith(customCell: ReviewScreenPreference.customItemCells[indexPath.row], indentifier: "CustomItemCell")
    }
    
    private func makeCellWith(customCell : MPCustomCell, indentifier : String) -> UITableViewCell {
        let screenSize : CGRect = UIScreen.main.bounds
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
    
    
    private func getSummaryCell(indexPath : IndexPath) -> UITableViewCell{
        let currency = MercadoPagoContext.getCurrency()
        let purchaseSimpleDetailTableViewCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "purchaseSimpleDetailTableViewCell", for: indexPath) as! PurchaseSimpleDetailTableViewCell
        purchaseSimpleDetailTableViewCell.fillCell(summaryRow: self.viewModel.summaryRows[indexPath.row], currency: currency, payerCost: nil)
        return purchaseSimpleDetailTableViewCell
    }
    
    private func getPurchaseSimpleDetailCell(indexPath : IndexPath, title : String, amount : Double, payerCost : PayerCost? = nil, addSeparatorLine : Bool = true) -> UITableViewCell{
        let currency = MercadoPagoContext.getCurrency()
        let purchaseSimpleDetailTableViewCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "purchaseSimpleDetailTableViewCell", for: indexPath) as! PurchaseSimpleDetailTableViewCell
        purchaseSimpleDetailTableViewCell.fillCell(title, amount: amount, currency: currency, payerCost: payerCost, addSeparatorLine : addSeparatorLine)
        return purchaseSimpleDetailTableViewCell
    }
    
    private func getConfirmAddtionalInfo( indexPath: IndexPath, payerCost: PayerCost?) -> UITableViewCell{
        let confirmAdditionalInfoCFT = self.checkoutTable.dequeueReusableCell(withIdentifier: "confirmAddtionalInfoCFT", for: indexPath) as! ConfirmAdditionalInfoTableViewCell
        confirmAdditionalInfoCFT.fillCell(payerCost: payerCost)
        return confirmAdditionalInfoCFT
    }
    
    private func getConfirmPaymentButtonCell(indexPath : IndexPath) -> UITableViewCell{
        let confirmPaymentTableViewCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "confirmPaymentTableViewCell", for: indexPath) as! ConfirmPaymentTableViewCell
        confirmPaymentTableViewCell.confirmPaymentButton.addTarget(self, action: #selector(confirmPayment), for: .touchUpInside)
		let confirmPaymentTitle = (indexPath.section == 1) ? MercadoPagoCheckoutViewModel.reviewScreenPreference.getConfirmButtonText() : "Confirmar".localized
        confirmPaymentTableViewCell.confirmPaymentButton.setTitle(confirmPaymentTitle,for: .normal)
        return confirmPaymentTableViewCell
    }
    
    private func getPurchaseItemDetailCell(indexPath : IndexPath) -> UITableViewCell{
        let currency = MercadoPagoContext.getCurrency()
        let purchaseItemDetailCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "purchaseItemDetailTableViewCell", for: indexPath) as! PurchaseItemDetailTableViewCell
        purchaseItemDetailCell.fillCell(item: (self.viewModel.preference!.items[indexPath.row]), currency: currency)
        return purchaseItemDetailCell
    }
    
    
    private func getOnlinePaymentMethodSelectedCell(indexPath : IndexPath) ->UITableViewCell {
        let paymentMethodSelectedTableViewCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "paymentMethodSelectedTableViewCell", for: indexPath) as! PaymentMethodSelectedTableViewCell
        
        paymentMethodSelectedTableViewCell.fillCell(self.viewModel.paymentData.paymentMethod!, amount : self.viewModel.getTotalAmount(), payerCost : self.viewModel.paymentData.payerCost, lastFourDigits: self.viewModel.paymentData.token!.lastFourDigits)
        
        paymentMethodSelectedTableViewCell.selectOtherPaymentMethodButton.addTarget(self, action: #selector(changePaymentMethodSelected), for: .touchUpInside)
        return paymentMethodSelectedTableViewCell
    }
    
    private func getOfflinePaymentMethodSelectedCell(indexPath : IndexPath) ->UITableViewCell {
        let offlinePaymentMethodCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "offlinePaymentMethodCell", for: indexPath) as! OfflinePaymentMethodCell
        offlinePaymentMethodCell.fillCell(self.viewModel.paymentOptionSelected, amount: self.viewModel.preference!.getAmount(), paymentMethod : self.viewModel.paymentData.paymentMethod!, currency: MercadoPagoContext.getCurrency())
        offlinePaymentMethodCell.changePaymentButton.addTarget(self, action: #selector(self.changePaymentMethodSelected), for: .touchUpInside)
        return offlinePaymentMethodCell
    }
    
    private func getCancelPaymentButtonCell(indexPath : IndexPath) -> UITableViewCell {
        let exitButtonCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "exitButtonCell", for: indexPath) as! ExitButtonTableViewCell
        let exitButtonTitle = MercadoPagoCheckoutViewModel.reviewScreenPreference.getCancelButtonTitle()
        exitButtonCell.exitButton.setTitle(exitButtonTitle, for: .normal)
        exitButtonCell.exitButton.addTarget(self, action: #selector(CheckoutViewController.exitCheckoutFlow), for: .touchUpInside)
        return exitButtonCell
    }
    
    private func getTermsAndConditionsCell(indexPath : IndexPath) -> UITableViewCell {
        let tycCell = self.checkoutTable.dequeueReusableCell(withIdentifier: "termsAndConditionsViewCell", for: indexPath) as! TermsAndConditionsViewCell
        tycCell.delegate = self
        return tycCell
    }
    
	func changePaymentMethodSelected() {
        let pm = PaymentData()
        pm.discount = self.viewModel.paymentData.discount
		self.callbackPaymentData(pm)
	}
    
	
    internal func openTermsAndConditions(_ title: String, url : URL){
        let webVC = WebViewController(url: url)
        webVC.title = title
        self.navigationController!.pushViewController(webVC, animated: true)
        
    }
 
    internal func exitCheckoutFlow(){
        self.callbackCancel!()
    }
    
    override func getNavigationBarTitle() -> String {
        if (self.checkoutTable.contentOffset.y == CheckoutViewController.kNavBarOffset || self.checkoutTable.contentOffset.y == CheckoutViewController.kNavBarOffset) {
            return ""
        }
        return MercadoPagoCheckoutViewModel.reviewScreenPreference.getTitle()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView){
        self.didScrollInTable(scrollView)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    public func invokeCallbackWithPaymentData(rowCallback : ((PaymentData) -> Void)) {
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
    
    private func removeStatusBar(){
        guard let _ = self.navigationController, let view = statusBarView else {
            return
        }
        view.removeFromSuperview()
    }
    
    private func displayStatusBar(){
    
        self.statusBarView = UIView(frame: CGRect(x: 0, y: -20, width: self.view.frame.width, height: 20))
        self.statusBarView!.backgroundColor = UIColor.grayStatusBar()
    
        
        self.statusBarView!.tag = 1
        
        self.navigationController!.navigationBar.barStyle = .blackTranslucent
        self.navigationController!.navigationBar.addSubview(self.statusBarView!)
    }
    
    
}

open class CheckoutViewModel {
    
    var shippingIncluded = false
    var freeShippingIncluded = false
    var discountIncluded = false
    
    var preference : CheckoutPreference?
    var paymentData : PaymentData!
    var paymentOptionSelected : PaymentMethodOption
    
    var discount : DiscountCoupon?
    
    var summaryRows = MercadoPagoCheckoutViewModel.reviewScreenPreference.getSummaryRows()
    
    public static var CUSTOMER_ID = ""
    
    init(checkoutPreference : CheckoutPreference, paymentData : PaymentData, paymentOptionSelected : PaymentMethodOption, discount: DiscountCoupon? = nil) {
        CheckoutViewModel.CUSTOMER_ID = ""
        self.preference = checkoutPreference
        self.paymentData = paymentData
        self.discount = discount
        self.paymentOptionSelected = paymentOptionSelected
        
        self.setSummaryRows()
    }
    
    func setSummaryRows() {
        
        let productsSummary = SummaryRow(customDescription: MercadoPagoCheckoutViewModel.reviewScreenPreference.getProductsTitle(), descriptionColor: nil, customAmount: self.preference!.getAmount(), amountColor: nil, separatorLine: shouldShowTotal())
        
        summaryRows.insert(productsSummary, at: 0)
        
        if let discount = self.paymentData.discount {
            let discountSummary = SummaryRow(customDescription: discount.getDiscountReviewDescription(), descriptionColor: UIColor.mpGreenishTeal(), customAmount:-Double(discount.coupon_amount)!, amountColor: UIColor.mpGreenishTeal(), separatorLine: false)
            summaryRows.insert(discountSummary, at: 1)
        }
    }
    
    func isPaymentMethodSelectedCard() -> Bool {
        return self.paymentData.paymentMethod != nil && self.paymentData.paymentMethod!.isCard()
    }
    
    func numberOfSections() -> Int {
        return self.preference != nil ? 6 : 0
    }
    
    func isPaymentMethodSelected() -> Bool {
        return paymentData.paymentMethod != nil
    }
    
    func checkoutTableHeaderHeight(_ section : Int) -> CGFloat {
        return 0
    }
    
    func numberOfRowsInMainSection() -> Int {
        // Productos
        var numberOfRows = 0
        
        if self.isPaymentMethodSelectedCard() {
            numberOfRows = numberOfRows +  1
        }
        
        if self.discountIncluded {
            numberOfRows = numberOfRows + 1
        }
        
        if self.shippingIncluded {
            numberOfRows = numberOfRows + 1
        }
        
        if hasPayerCostAddionalInfo() {
            numberOfRows += 1
        }
        // Productos + customSummaryRows
        numberOfRows += summaryRows.count
        
        // Total
        numberOfRows = numberOfRows + 1
        return numberOfRows
        
    }
    func heightForRow(_ indexPath: IndexPath) -> CGFloat {
        if isTitleCellFor(indexPath: indexPath) {
            return 60
        
        } else if self.isProductlCellFor(indexPath: indexPath) {
           return PurchaseSimpleDetailTableViewCell.ROW_HEIGHT
        
        } else if self.isInstallmentsCellFor(indexPath: indexPath) {
           return PurchaseDetailTableViewCell.getCellHeight(payerCost : self.paymentData.payerCost)
            
        } else if self.isTotalCellFor(indexPath: indexPath) {
            return PurchaseSimpleDetailTableViewCell.ROW_HEIGHT
            
        } else if self.isConfirmAdditionalInfoFor(indexPath: indexPath) {
            return ConfirmAdditionalInfoTableViewCell.ROW_HEIGHT
        
        } else if self.isConfirmButtonCellFor(indexPath: indexPath) {
            return ConfirmPaymentTableViewCell.ROW_HEIGHT
            
        } else if self.isItemCellFor(indexPath: indexPath) {
            return hasCustomItemCells() ? ReviewScreenPreference.customItemCells[indexPath.row].getHeight() : PurchaseItemDetailTableViewCell.getCellHeight(item: self.preference!.items[indexPath.row])
            
        } else if self.isPaymentMethodCellFor(indexPath: indexPath) {
                return PaymentMethodSelectedTableViewCell.getCellHeight(payerCost : self.paymentData.payerCost)
        
        } else if self.isAddtionalCustomCellsFor(indexPath: indexPath) {
            return ReviewScreenPreference.additionalInfoCells[indexPath.row].getHeight()
            
        } else if isTermsAndConditionsViewCellFor(indexPath: indexPath) {
            return TermsAndConditionsViewCell.getCellHeight()
        
        } else if isConfirmPaymentTableViewCellFor(indexPath: indexPath) {
            return ConfirmPaymentTableViewCell.ROW_HEIGHT
        
        } else if isExitButtonTableViewCellFor(indexPath: indexPath) {
            return ExitButtonTableViewCell.ROW_HEIGHT
        }

        return 0
    }
        
    func isTermsAndConditionsViewCellFor(indexPath: IndexPath) -> Bool{
        if !isFotterCellFor(indexPath: indexPath) {
            return false
        }
        return ( indexPath.row == 0 && String.isNullOrEmpty(MercadoPagoContext.payerAccessToken()) )
    }
    func isConfirmPaymentTableViewCellFor(indexPath: IndexPath) -> Bool{
        if !isFotterCellFor(indexPath: indexPath) {
            return false
        }
        return ( indexPath.row == 1 && String.isNullOrEmpty(MercadoPagoContext.payerAccessToken()) ) || ( indexPath.row == 0 && !String.isNullOrEmpty(MercadoPagoContext.payerAccessToken()) )
    }
    func isExitButtonTableViewCellFor(indexPath: IndexPath) -> Bool{
        if !isFotterCellFor(indexPath: indexPath) {
            return false
        }
        return ( indexPath.row == 2 && String.isNullOrEmpty(MercadoPagoContext.payerAccessToken()) ) || ( indexPath.row == 1 && !String.isNullOrEmpty(MercadoPagoContext.payerAccessToken()) )
    }
    func isPreferenceLoaded() -> Bool {
        return self.preference != nil
    }
    
    func shouldDisplayNoRate() -> Bool {
        return self.paymentData.payerCost != nil && !self.paymentData.payerCost!.hasInstallmentsRate() && self.paymentData.payerCost!.installments != 1
    }
    
    func numberOfCustomAdditionalCells() -> Int {
        if !Array.isNullOrEmpty(ReviewScreenPreference.additionalInfoCells) {
            return ReviewScreenPreference.additionalInfoCells.count
        }
        return 0
    }
    
    func numberOfCustomItemCells() -> Int {
        if hasCustomItemCells() {
            return ReviewScreenPreference.customItemCells.count
        }
        return 0
    }
    
    func hasCustomItemCells() -> Bool {
        return !Array.isNullOrEmpty(ReviewScreenPreference.customItemCells)
    }
    
    func numberOfSummaryRows() -> Int{
        return summaryRows.count
    }
    
    func getTotalAmount() -> Double {
        if let payerCost = paymentData.payerCost {
            return payerCost.totalAmount
        }
        if let discount = paymentData.discount {
            return discount.newAmount()
        }
        return self.preference!.getAmount()
    }
    
    func hasPayerCostAddionalInfo() -> Bool {
        return self.paymentData.payerCost != nil && self.paymentData.payerCost!.getCFTValue() != nil
    }
    
    func isTitleCellFor(indexPath: IndexPath) -> Bool{
        return indexPath.section == 0
    }
    
    func isProductlCellFor(indexPath: IndexPath) -> Bool{
        return indexPath.section == 1 && indexPath.row < numberOfSummaryRows()
    }
    
    func isInstallmentsCellFor(indexPath: IndexPath) -> Bool{
        return shouldShowInstallmentSummary() && indexPath.section == 1 && indexPath.row == numberOfSummaryRows()
           
    }
    func isTotalCellFor(indexPath: IndexPath) -> Bool {
        let numberOfRows = numberOfSummaryRows() + (shouldShowInstallmentSummary() ? 1 : 0)
        return shouldShowTotal() && indexPath.section == 1 && indexPath.row == numberOfRows
    }
    
    func isConfirmButtonCellFor(indexPath: IndexPath) -> Bool {
        var numberOfRows = numberOfSummaryRows()
        numberOfRows += shouldShowTotal() ? 1 : 0
        numberOfRows += shouldShowInstallmentSummary() ? 1 : 0
        numberOfRows += hasPayerCostAddionalInfo() ? 1 : 0
        return indexPath.section == 1 && indexPath.row == numberOfRows
    }
    
    func isItemCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == 2
    }
    
    func isConfirmAdditionalInfoFor(indexPath: IndexPath) -> Bool {
        let numberOfRows = numberOfSummaryRows() + (shouldShowTotal() ? 1 : 0) + (shouldShowInstallmentSummary() ? 1 : 0)
        return hasPayerCostAddionalInfo() && indexPath.section == 1 && indexPath.row == numberOfRows
    }
    
    func isAddtionalCustomCellsFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == 4
    }
    
    func isFotterCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == 5
    }
    
    func isPaymentMethodCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == 3
    }
    
    func shouldShowTotal() -> Bool {
        return shouldShowInstallmentSummary() || numberOfSummaryRows() != 1
    }
    
    func shouldShowInstallmentSummary() -> Bool {
        return isPaymentMethodSelectedCard() && self.paymentData.paymentMethod.paymentTypeId != "debit_card"
    }
}

@objc public protocol MPCustomRowDelegate {
    
    @objc optional func invokeCallbackWithPaymentData(rowCallback : ((PaymentData) -> Void))
    
    @objc optional func invokeCallbackWithPaymentResult(rowCallback : ((PaymentResult) -> Void))

}
