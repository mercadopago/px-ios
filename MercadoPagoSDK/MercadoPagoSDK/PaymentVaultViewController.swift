//
//  PaymentVaultViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit


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

open class PaymentVaultViewController: MercadoPagoUIScrollViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionSearch: UICollectionView!

    override open var screenName: String { get { return TrackingUtil.SCREEN_NAME_PAYMENT_VAULT} }
    override open var screenId: String { get { return TrackingUtil.SCREEN_ID_PAYMENT_VAULT} }

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

    var titleSectionReference: PaymentVaultTitleCollectionViewCell!

    fileprivate var tintColor = true
    fileprivate var loadingGroups = true

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
        var finalId = screenId
        if let groupName = groupName {
            finalId = screenId + "/" + groupName
        }
        MPXTracker.trackScreen(screenId: finalId, screenName: screenName)
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
        //self.showLoading()

        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCoupon(_:)), name: NSNotification.Name(rawValue: "MPSDK_UpdateCoupon"), object: nil)

        var upperFrame = self.collectionSearch.bounds
        upperFrame.origin.y = -upperFrame.size.height + 10
        upperFrame.size.width = UIScreen.main.bounds.width
        let upperView = UIView(frame: upperFrame)
        upperView.backgroundColor = UIColor.primaryColor()
        collectionSearch.addSubview(upperView)

        if self.title == nil || self.title!.isEmpty {
            self.title = "¿Cómo quiéres pagar?".localized
        }

        self.registerAllCells()

        if callbackCancel == nil {
            self.callbackCancel = {() -> Void in
                if self.navigationController?.viewControllers[0] == self {
                    self.dismiss(animated: true, completion: {

                    })
                } else {
                    self.navigationController!.popViewController(animated: true)
                }
            }
        } else {
            self.callbackCancel = callbackCancel
        }

       self.collectionSearch.backgroundColor = UIColor.px_white()

    }

    func updateCoupon(_ notification: Notification) {
        if let discount = notification.userInfo?["coupon"] as? DiscountCoupon {
            self.viewModel.discount = discount
            self.collectionSearch.reloadData()
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.hideNavBar()
        if let button = self.navigationItem.leftBarButtonItem {
               self.navigationItem.leftBarButtonItem!.action = #selector(invokeCallbackCancelShowingNavBar)
        }

        self.navigationController!.navigationBar.shadowImage = nil
        self.extendedLayoutIncludesOpaqueBars = true
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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

    open override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    fileprivate func cardFormCallbackCancel() -> (() -> Void) {
        return { () -> Void in
            if self.viewModel.getDisplayedPaymentMethodsCount() > 1 {
                self.navigationController!.popToViewController(self, animated: true)
            } else {
                self.loadingGroups = false
              //  self.navigationController!.popToViewController(self, animated: true)
                self.callbackCancel!()
            }
        }
    }

    fileprivate func getCustomerCards() {
        if self.viewModel!.shouldGetCustomerCardsInfo() {

            if let customerURL = MercadoPagoCheckoutViewModel.servicePreference.getCustomerURL() {
                MercadoPagoServicesAdapter.getCustomer(additionalInfo: MercadoPagoCheckoutViewModel.servicePreference.customerAdditionalInfo, callback: { [weak self] (customer) in
                    
                    self?.viewModel.customerId = customer._id
                    self?.viewModel.customerPaymentOptions = customer.cards
                    self?.loadPaymentMethodSearch()
                    
                }, failure: { (error) in
                    
                    // Ir a Grupos igual
                    self.loadPaymentMethodSearch()
                    
                })
            }

        } else {
            self.loadPaymentMethodSearch()
        }
    }

    fileprivate func hideNavBarCallbackDisplayTitle() -> (() -> Void) {
        return { () -> Void in
            if self.titleSectionReference != nil {
                self.titleSectionReference.fillCell()
            }
        }
    }

    fileprivate func loadPaymentMethodSearch() {

        if Array.isNullOrEmpty(self.viewModel.paymentMethodOptions) {
            MercadoPagoServicesAdapter.getPaymentMethodSearch(amount: self.viewModel.amount, excludedPaymentTypesIds: viewModel.getExcludedPaymentTypeIds(), excludedPaymentMethodsIds: viewModel.getExcludedPaymentMethodIds(), defaultPaymentMethod: self.viewModel.getPaymentPreferenceDefaultPaymentMethodId(), payer: Payer(), site: MercadoPagoContext.getSite(), callback: { (paymentMethodSearch) in

                if paymentMethodSearch.customerPaymentMethods?.count == 0 && paymentMethodSearch.groups.count == 0 {
                    let error = MPSDKError(message: "Hubo un error".localized, errorDetail: "No se ha podido obtener los métodos de pago con esta preferencia".localized, retry: false)
                    self.displayFailure(error)
                }

                self.loadPaymentMethodSearch()

            }, failure: { (error) in

                self.requestFailure(error, requestOrigin: ApiUtil.RequestOrigin.PAYMENT_METHOD_SEARCH.rawValue, callback: {
                    self.navigationController!.dismiss(animated: true, completion: {})
                }, callbackCancel: {
                    self.invokeCallbackCancelShowingNavBar()
                })

            })

//            MercadoPagoServices.searchPaymentMethods(self.viewModel.amount, defaultPaymenMethodId: self.viewModel.getPaymentPreferenceDefaultPaymentMethodId(), excludedPaymentTypeIds: viewModel.getExcludedPaymentTypeIds(), excludedPaymentMethodIds: viewModel.getExcludedPaymentMethodIds(), baseURL: MercadoPagoCheckoutViewModel.servicePreference.getDefaultBaseURL(), success: { (paymentMethodSearchResponse: PaymentMethodSearch) -> Void in
//                if paymentMethodSearchResponse.customerPaymentMethods?.count == 0 && paymentMethodSearchResponse.groups.count == 0 {
//                    let error = MPSDKError(message: "Hubo un error".localized, errorDetail: "No se ha podido obtener los métodos de pago con esta preferencia".localized, retry: false)
//                    self.displayFailure(error)
//                }
//
//                self.loadPaymentMethodSearch()
//
//            }, failure: { (error) -> Void in
//                self.requestFailure(error, requestOrigin: ApiUtil.RequestOrigin.PAYMENT_METHOD_SEARCH.rawValue, callback: {
//                    self.navigationController!.dismiss(animated: true, completion: {})
//                }, callbackCancel: {
//                    self.invokeCallbackCancelShowingNavBar()
//                })
//            })

        } else {
            self.collectionSearch.delegate = self
            self.collectionSearch.dataSource = self
            self.collectionSearch.reloadData()
            self.loadingGroups = false

            if self.viewModel.getDisplayedPaymentMethodsCount() == 1 {
                let paymentOptionDefault = self.viewModel.getPaymentMethodOption(row: 0) as! PaymentMethodOption
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

    }

    override func getNavigationBarTitle() -> String {
        if self.titleSectionReference != nil {
            self.titleSectionReference.title.text = ""
        }
        return "¿Cómo quiéres pagar?".localized
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        return MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable() ? 3 : 2
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isGroupSection(section: indexPath.section) {
            let paymentSearchItemSelected = self.viewModel.getPaymentMethodOption(row: indexPath.row) as! PaymentMethodOption
            collectionView.deselectItem(at: indexPath, animated: true)
            collectionView.allowsSelection = false
            self.callback!(paymentSearchItemSelected)

        } else if isCouponSection(section: indexPath.section) {
            if let coupon = self.viewModel.discount {
                let step = CouponDetailViewController(coupon: coupon)
                self.present(step, animated: false, completion: {})
            } else {
                let step = AddCouponViewController(amount: self.viewModel.amount, email: self.viewModel.email, callback: { (coupon) in
                    self.viewModel.discount = coupon
                    self.collectionSearch.reloadData()
                    if let updateMercadoPagoCheckout = self.viewModel.couponCallback {
                        updateMercadoPagoCheckout(coupon)
                    }
                })
                self.present(step, animated: false, completion: {})
            }
        }
    }

    func isHeaderSection(section: Int) -> Bool {
        return section == 0
    }
    func isCouponSection(section: Int) -> Bool {
        return MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable() && section == 1
    }

    func isGroupSection(section: Int) -> Bool {
        let sectionGroup = MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable() ? 2 :1

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

            return self.viewModel.getDisplayedPaymentMethodsCount()

    }

    public func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCollectionCell",

                                                      for: indexPath) as! PaymentSearchCollectionViewCell

        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "paymentVaultTitleCollectionViewCell",

                                                          for: indexPath) as! PaymentVaultTitleCollectionViewCell
            self.titleSectionReference = cell
            titleCell = cell
            return cell
        } else if isGroupSection(section: indexPath.section) {
            let paymentMethodToDisplay = self.viewModel.getPaymentMethodOption(row: indexPath.row)
            cell.fillCell(drawablePaymentOption: paymentMethodToDisplay)
        } else if isCouponSection(section: indexPath.section) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CouponCell", for: indexPath)
            cell.contentView.viewWithTag(1)?.removeFromSuperview()
            let discountBody = DiscountBodyCell(frame: CGRect(x: 0, y: 0, width : view.frame.width, height : DiscountBodyCell.HEIGHT), coupon: self.viewModel.discount, amount:self.viewModel.amount, topMargin: 15)
            discountBody.tag = 1
            cell.contentView.addSubview(discountBody)
            return cell
        }
        return cell

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
            return CGSize(width : view.frame.width, height : titleCellHeight)
        }
        if isCouponSection(section: indexPath.section) {
            return CGSize(width : view.frame.width, height : DiscountBodyCell.HEIGHT + 20) // Add 20 px to separate sections
        }

        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: maxHegithRow(indexPath:indexPath)  )
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
        return PaymentSearchCollectionViewCell.totalHeight(drawablePaymentOption : self.viewModel.getPaymentMethodOption(row: indexItem))
    }

    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if isCouponSection(section: section) {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

 }
