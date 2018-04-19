//
//  PaymentVaultViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoPXTracking

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

@objcMembers
open class PaymentVaultViewController: MercadoPagoUIScrollViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionSearch: UICollectionView!

    override open var screenName: String { return TrackingUtil.SCREEN_NAME_PAYMENT_VAULT }
    override open var screenId: String { return TrackingUtil.SCREEN_ID_PAYMENT_VAULT }

    static let VIEW_CONTROLLER_NIB_NAME: String = "PaymentVaultViewController"

    var merchantBaseUrl: String!
    var merchantAccessToken: String!
    var publicKey: String!
    var currency: Currency!

    var groupName: String?

    var defaultInstallments: Int?
    var installments: Int?
    var viewModel: PaymentVaultViewModel!

    var bundle = MercadoPago.getBundle()

    var titleSectionReference: PaymentVaultTitleCollectionViewCell?

    fileprivate var tintColor = true
    fileprivate var loadingGroups = true

    fileprivate let TOTAL_ROW_HEIGHT: CGFloat = 42.0

    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)

    fileprivate var defaultOptionSelected = false

    fileprivate var callback : ((_ paymentMethodSelected: PaymentMethodOption) -> Void)!

    init(viewModel: PaymentVaultViewModel, callback : @escaping (_ paymentMethodSelected: PaymentMethodOption) -> Void) {
        super.init(nibName: PaymentVaultViewController.VIEW_CONTROLLER_NIB_NAME, bundle: bundle)
        self.initCommon()
        self.viewModel = viewModel
        if let groupName = self.viewModel.groupName {
            self.groupName = groupName
        }
        self.callback = callback
    }

    override func trackInfo() {
        let paymentMethodsOptions = PXTrackingStore.sharedInstance.getData(forKey: PXTrackingStore.PAYMENT_METHOD_OPTIONS) ?? ""
        let properties: [String: String] = [TrackingUtil.METADATA_OPTIONS: paymentMethodsOptions]
        var finalId = screenId
        if let groupName = groupName {
            finalId = screenId + "/" + groupName
        }
        MPXTracker.sharedInstance.trackScreen(screenId: finalId, screenName: screenName, properties: properties)
    }

    fileprivate func initCommon() {
        self.merchantAccessToken = MercadoPagoContext.merchantAccessToken()
        self.publicKey = MercadoPagoContext.publicKey()
        self.currency = MercadoPagoContext.getCurrency()
    }

    required  public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCoupon(_:)), name: NSNotification.Name(rawValue: "MPSDK_UpdateCoupon"), object: nil)

        var upperFrame = self.collectionSearch.bounds
        upperFrame.origin.y = -upperFrame.size.height + 10
        upperFrame.size.width = UIScreen.main.bounds.width
        let upperView = UIView(frame: upperFrame)
        upperView.backgroundColor = UIColor.primaryColor()
        collectionSearch.addSubview(upperView)

        if self.title == nil || self.title!.isEmpty {
            self.title = "¿Cómo quieres pagar?".localized
        }

        self.registerAllCells()

        if callbackCancel == nil {
            self.callbackCancel = { [weak self] () -> Void in
                if let targetVC = self?.navigationController?.viewControllers[0], let currentVC = self, targetVC == currentVC {
                    self?.dismiss(animated: true, completion: {})
                } else {
                    self?.navigationController!.popViewController(animated: true)
                }
            }
        } else {
            self.callbackCancel = callbackCancel
        }

       self.collectionSearch.backgroundColor = UIColor.white
    }

    @objc func updateCoupon(_ notification: Notification) {
        if let discount = notification.userInfo?["coupon"] as? DiscountCoupon {
            self.viewModel.discount = discount
            self.collectionSearch.reloadData()
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.hideNavBar()

        if let leftBarButtonItem = self.navigationItem.leftBarButtonItem {
            leftBarButtonItem.action = #selector(invokeCallbackCancelShowingNavBar)
        }

        self.navigationController!.navigationBar.shadowImage = nil
        self.extendedLayoutIncludesOpaqueBars = true

        self.collectionSearch.allowsSelection = true
        self.getCustomerCards()
        self.hideNavBarCallback = self.hideNavBarCallbackDisplayTitle()
        if self.loadingGroups {
            let temporalView = UIView.init(frame: CGRect(x: 0, y: navBarHeigth + statusBarHeigth, width: self.view.frame.size.width, height: self.view.frame.size.height))
            temporalView.backgroundColor?.withAlphaComponent(0)
            temporalView.isUserInteractionEnabled = false
            self.view.addSubview(temporalView)
        }
        self.hideLoading()
    }

    fileprivate func cardFormCallbackCancel() -> (() -> Void) {
        return { () -> Void in
            if self.viewModel.getDisplayedPaymentMethodsCount() > 1 {
                self.navigationController!.popToViewController(self, animated: true)
            } else {
                self.loadingGroups = false
                self.callbackCancel!()
            }
        }
    }

    fileprivate func getCustomerCards() {

        if self.viewModel!.shouldGetCustomerCardsInfo() {
            if MercadoPagoCheckoutViewModel.servicePreference.getCustomerURL() != nil {
                self.viewModel.mercadoPagoServicesAdapter.getCustomer(callback: { [weak self] (customer) in
                    self?.viewModel.customerId = customer.customerId
                    self?.viewModel.customerPaymentOptions = customer.cards
                    self?.loadPaymentMethodSearch()
                }, failure: { (_) in
                    // Ir a Grupos igual
                    self.loadPaymentMethodSearch()
                })
            }
        } else {
            self.loadPaymentMethodSearch()
        }
    }

    fileprivate func hideNavBarCallbackDisplayTitle() -> (() -> Void) {
        return { [weak self] () -> Void in
            self?.titleSectionReference?.fillCell()
        }
    }

    fileprivate func loadPaymentMethodSearch() {
        self.collectionSearch.delegate = self
        self.collectionSearch.dataSource = self
        self.collectionSearch.reloadData()
        self.loadingGroups = false

        if self.viewModel.getDisplayedPaymentMethodsCount() == 1 {
            if let paymentOptionDefault = self.viewModel.getPaymentMethodOption(row: 0) as? PaymentMethodOption {
                self.callback(paymentOptionDefault)
            }
        }
    }

    fileprivate func registerAllCells() {
        let collectionSearchCell = UINib(nibName: "PaymentSearchCollectionViewCell", bundle: self.bundle)
        self.collectionSearch.register(collectionSearchCell, forCellWithReuseIdentifier: "searchCollectionCell")

        let paymentVaultTitleCollectionViewCell = UINib(nibName: "PaymentVaultTitleCollectionViewCell", bundle: self.bundle)
        self.collectionSearch.register(paymentVaultTitleCollectionViewCell, forCellWithReuseIdentifier: "paymentVaultTitleCollectionViewCell")

        self.collectionSearch.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "CouponCell")

        self.collectionSearch.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "TotalAmountCell")
    }

    override func getNavigationBarTitle() -> String {
        if let cellRef = self.titleSectionReference {
            cellRef.title.text = ""
        }
        return "¿Cómo quieres pagar?".localized
    }

    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        //En caso de que el vc no sea root
        if (navigationController != nil && navigationController!.viewControllers.count > 1 && navigationController!.viewControllers[0] != self) || (navigationController != nil && navigationController!.viewControllers.count == 1) {
            if self.viewModel!.isRoot {
                self.callbackCancel!()
            }
            return true
        }
        return false
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.loadingGroups {
            return 0
        }
        return 3
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if isGroupSection(section: indexPath.section) {

            if let paymentSearchItemSelected = self.viewModel.getPaymentMethodOption(row: indexPath.row) as? PaymentMethodOption {
                collectionView.deselectItem(at: indexPath, animated: true)
                collectionView.allowsSelection = false
                self.callback!(paymentSearchItemSelected)
            }

        } else if isCouponSection(section: indexPath.section) {
            if let coupon = self.viewModel.discount {
                let step = CouponDetailViewController(coupon: coupon)
                self.present(step, animated: false, completion: {})
            } else {
                let step = AddCouponViewController(amount: self.viewModel.amount, email: self.viewModel.email, mercadoPagoServicesAdapter: self.viewModel.mercadoPagoServicesAdapter, callback: { (coupon) in
                    self.viewModel.discount = coupon
                    self.collectionSearch.reloadData()
                    if let updateMercadoPagoCheckout = self.viewModel.couponCallback {
                        updateMercadoPagoCheckout(coupon)
                    }
                })
                self.navigationController?.pushViewController(step, animated: true)
            }
        }
    }

    func isHeaderSection(section: Int) -> Bool {
        return section == 0
    }
    func isCouponSection(section: Int) -> Bool {
        return MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable() && section == 1
    }
    func isTotalSection(section: Int) -> Bool {
        return !MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable() && section == 1
    }

    func isGroupSection(section: Int) -> Bool {
        let sectionGroup = 2

        return sectionGroup == section
    }

    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        if loadingGroups {
            return 0
        }
        if isHeaderSection(section: section) {
            return 1
        }
        if isCouponSection(section: section) {
            return 1
        }
        if isTotalSection(section: section) {
            return 1
        }

        return self.viewModel.getDisplayedPaymentMethodsCount()
    }

    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "paymentVaultTitleCollectionViewCell", for: indexPath) as? PaymentVaultTitleCollectionViewCell else { return UICollectionViewCell.init() }
            self.titleSectionReference = cell
            titleCell = cell
            return cell
        } else if isGroupSection(section: indexPath.section) {

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCollectionCell", for: indexPath) as? PaymentSearchCollectionViewCell else { return UICollectionViewCell.init() }

            if let paymentMethodToDisplay = self.viewModel.getPaymentMethodOption(row: indexPath.row) {
                cell.fillCell(drawablePaymentOption: paymentMethodToDisplay)
            }

            return cell

        } else if isCouponSection(section: indexPath.section) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CouponCell", for: indexPath)
            cell.contentView.viewWithTag(1)?.removeFromSuperview()
            let discountBody = DiscountBodyCell(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: DiscountBodyCell.HEIGHT), coupon: self.viewModel.discount, amount: self.viewModel.amount, topMargin: 20)
            discountBody.tag = 1
            cell.contentView.addSubview(discountBody)
            return cell
        } else if isTotalSection(section: indexPath.section) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TotalAmountCell", for: indexPath)
            for view in cell.contentView.subviews {
                view.removeFromSuperview()
            }

            let amountFontSize: CGFloat = PXLayout.XS_FONT
            let centsFontSize: CGFloat = PXLayout.XXXS_FONT
            let currency = MercadoPagoContext.getCurrency()
            let currencySymbol = currency.getCurrencySymbolOrDefault()
            let thousandSeparator = currency.getThousandsSeparatorOrDefault()
            let decimalSeparator = currency.getDecimalSeparatorOrDefault()
            let attributedTitle = NSMutableAttributedString(string: "Total: ".localized, attributes: [NSAttributedStringKey.font: Utils.getFont(size: amountFontSize)])

            let attributedAmount = Utils.getAttributedAmount(self.viewModel.amount, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator, currencySymbol: currencySymbol, color: UIColor.px_white(), fontSize: amountFontSize, centsFontSize: centsFontSize, baselineOffset: 3, smallSymbol: false)
            attributedTitle.append(attributedAmount)

            let props = PXContainedLabelProps(labelText: attributedTitle)
            let component = PXContainedLabelComponent(props: props)
            let view = component.render()
            cell.contentView.addSubview(view)
            PXLayout.matchHeight(ofView: view).isActive = true
            PXLayout.matchWidth(ofView: view).isActive = true
            PXLayout.centerVertically(view: view).isActive = true
            PXLayout.centerHorizontally(view: view).isActive = true
            view.addSeparatorLineToBottom(height: 1)
            return cell
        }
        return UICollectionViewCell()

    }

    fileprivate let itemsPerRow: CGFloat = 2

    var sectionHeight: CGSize?

    override func scrollPositionToShowNavBar () -> CGFloat {
        return titleCellHeight - navBarHeigth - statusBarHeigth
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {

        let paddingSpace = CGFloat(32.0)
        let availableWidth = view.frame.width - paddingSpace

        titleCellHeight = 82
        if isHeaderSection(section: indexPath.section) {
            return CGSize(width: view.frame.width, height: titleCellHeight)
        }
        if isCouponSection(section: indexPath.section) {
            return CGSize(width: view.frame.width, height: DiscountBodyCell.HEIGHT + 20) // Add 20 px to separate sections
        }
        if isTotalSection(section: indexPath.section) {
            return CGSize(width: view.frame.width, height: self.TOTAL_ROW_HEIGHT)
        }

        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: maxHegithRow(indexPath: indexPath))
    }

    private func maxHegithRow(indexPath: IndexPath) -> CGFloat {
        return self.calculateHeight(indexPath: indexPath, numberOfCells: self.viewModel.getDisplayedPaymentMethodsCount())
    }

    private func calculateHeight(indexPath: IndexPath, numberOfCells: Int) -> CGFloat {
        if numberOfCells == 0 {
            return 0
        }

        let section: Int
        let row = indexPath.row
        if row % 2 == 1 {
            section = (row - 1) / 2
        } else {
            section = row / 2
        }
        let index1 = (section  * 2)
        let index2 = (section  * 2) + 1

        if index1 + 1 > numberOfCells {
            return 0
        }

        let height1 = heightOfItem(indexItem: index1)

        if index2 + 1 > numberOfCells {
            return height1
        }

        let height2 = heightOfItem(indexItem: index2)

        return height1 > height2 ? height1 : height2
    }

    func heightOfItem(indexItem: Int) -> CGFloat {
        if let paymentMethodOptionDrawable = self.viewModel.getPaymentMethodOption(row: indexItem) {

            return PaymentSearchCollectionViewCell.totalHeight(drawablePaymentOption: paymentMethodOptionDrawable)
        }
        return 0
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        if isCouponSection(section: section) {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        if isTotalSection(section: section) {
            return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }
        if isHeaderSection(section: section) {
            return UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
        }
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.didScrollInTable(scrollView)
    }
 }
